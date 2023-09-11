module AzureOpenAi
  module Agents
    class Reviewer < Base
      def initialize(leader_comment, color)
        super(leader_comment, color)

        @record_lgtm_function = AzureOpenAi::Functions::RecordLgtm.new
      end

      def lgtm?
        @record_lgtm_function.lgtm?
      end

      def work(programmer_comment: nil)
        puts("---------------------------------".send(@color))
        puts("#{self.actor_name}: start to work".send(@color))

        message_container = LlmMessageContainer.new
        message_container.add_system_message(("あなたは優れたRubyプログラムのレビュアーです。\n" + \
          "エンジニアリーダーからの要求に対するプログラマーによる修正をレビューし、徹底的にチェックし、" + \
          "さらなる注意が必要なポイントを特定し、それらを日本語でプログラマーに指摘します。\n" + \
          "何かわからないことがあれば、google_searchやopen_urlを使ってヒントを探してください。\n" + \
          "レビューする際には、特に以下の点に注意してください:\n" + \
          "- gemを追加するときは、Gemfileも修正してbundle installが通ることを確認します。\n" + \
          "- 修正されたコードは、自然なデザインで、適切で理解しやすい変数名を利用した読みやすいコードでなければなりません。\n" + \
          "- RubyスクリプトにはRspecテストが実装されています。" + \
            "ciを修正するときは、ciによって実行されるプログラムが正しく動作すること。\n" + \
          "- Rubyファイルを修正するときは、rspecが正しく動作すること。\n" + \
          "すべてのチェックが完了し、問題が見つからなければ、必ずreport_lgtm関数を実行します。\n\n" + \
          "エンジニアリーダーからの要求は以下の通りです。\n").to_en + @leader_comment.wrap_as_markdown)
        if programmer_comment.present?
          message_container.add_system_message(
            "現在の差分に対して、プログラマーから以下のコメントがありました。".to_en + "\n#{programmer_comment}")
        end

        diff = self.get_current_diff
        message_container.add_system_message("現在の差分は以下のとおりです。".to_en + "\n#{diff}")

        azure_open_ai = AzureOpenAi::Client.new
        io, _, _ = azure_open_ai.chat_with_function_calling_loop(
          messages: message_container,
          functions: [
            @record_lgtm_function,
            AzureOpenAi::Functions::GetFilesList.new,
            AzureOpenAi::Functions::ReadFile.new,

            AzureOpenAi::Functions::ExecRspecTest.new,
            AzureOpenAi::Functions::ExecShellCommand.new,

            AzureOpenAi::Functions::GoogleSearch.new,
            AzureOpenAi::Functions::OpenUrl.new,
          ],
          color: @color,
          actor_name: self.actor_name,
        )

        comment = io.rewind && io.read
        puts("#{self.class.name.split('::').last}: #{comment}".send(@color))
        comment
      end
    end
  end
end