module AzureOpenAi
  module Agents
    class Programmer < Base
      def work(reviewer_comment: nil)
        puts("---------------------------------".send(@color))
        puts("#{self.actor_name}: start to work".send(@color))

        message_container = LlmMessageContainer.new
        message_container.add_system_message(("あなたは優れたRubyのプログラマーです。\n" + \
          "エンジニアリーダーからの指示に基づいて、このリポジトリに適切な修正を加えてください。\n" + \
          "修正が完了したら、Railsランナーやシェルコマンドを使って、修正が意図した通りに完了していることを確認してください。\n" + \
          "プログラムのポリシーはあなた自身で決定する責任があります。テストコードを実装する際には、対象クラスの実装から仕様を想像し、テストケースを具体的に実装してください。\n" + \
          "そして、rspecの結果を確認し、一つずつテストが通るように修正してください。\n" + \
          "基本的には、実装側を修正しないでください。もし実装側にバグが含まれている場合は、実装側を修正してください。\n" + \
          "テストに関連するすべてのダミーファイルは、specフォルダの下に作成してください。\n" + \
          "ファイルを修正する際には、まずread_fileを行い、適切にインデントを行ってください。\n" + \
          "何かわからないことがあれば、google_searchやopen_urlを使ってヒントを探してください。\n" + \
          "あなたは唯一のプログラマーです。問題がある間はレビュアーに問題をなげず、問題を解決してからレビュアーに返答してください。\n" + \
          "修正が完了したら、日本語でレビュアーにあなたの懸念を伝えてください。\n" + \
          "エンジニアリーダーからの要求は以下の通りです。\n").to_en + @leader_comment.wrap_as_markdown)
        if reviewer_comment.present?
          message_container.add_system_message(
            "現在の差分に対して、レビュワーから以下のコメントがありました。".to_en + "\n#{reviewer_comment}")
        end

        if diff = self.get_current_diff
          message_container.add_system_message("現在の差分は以下のとおりです。".to_en + "\n#{diff}")
        end

        azure_open_ai = AzureOpenAi::Client.new
        io, _, _ = azure_open_ai.chat_with_function_calling_loop(
          messages: message_container,
          functions: [
            AzureOpenAi::Functions::GetFilesList.new,
            AzureOpenAi::Functions::ReadFile.new,
            AzureOpenAi::Functions::AppendTextToFile.new,
            AzureOpenAi::Functions::ModifyTextOfFile.new,
            AzureOpenAi::Functions::MakeNewFile.new,

            AzureOpenAi::Functions::ExecRspecTest.new,
            AzureOpenAi::Functions::ExecShellCommand.new,

            AzureOpenAi::Functions::GoogleSearch.new,
            AzureOpenAi::Functions::OpenUrl.new,
          ],
          color: @color,
          actor_name: self.actor_name,
        )

        comment = io.rewind && io.read
        puts("#{self.actor_name}: #{comment}".send(@color))
        comment
      end

      def make_pr!
        generate_pr_params_function = AzureOpenAi::Functions::GeneratePullRequestParams.new
        azure_open_ai = AzureOpenAi::Client.new
        io, _, _ = azure_open_ai.chat_with_function_calling_loop(
          messages: [
            {
              role: :system,
              content: "You are an excellent Ruby programmer. \n" + \
                "Please call generate appropriate pull request parameter function for the following diff.\n\n #{self.get_current_diff}",
            }
          ],
          functions: [generate_pr_params_function],
          color: @color,
          actor_name: self.actor_name,
        )
        issue_number = ENV['ISSUE_NUMBER'].blank? ? '' : " ##{ENV['ISSUE_NUMBER']}"
        exec_sh("git checkout -b #{generate_pr_params_function.branch_name}")
        exec_sh("git add .")
        exec_sh("git commit -m '#{generate_pr_params_function.title}'")
        exec_sh("git push --set-upstream origin #{generate_pr_params_function.branch_name}")
        exec_sh("gh pr create --base main --head #{generate_pr_params_function.branch_name} " + \
          "--title '#{generate_pr_params_function.title}#{issue_number}' --body '#{generate_pr_params_function.description}'")
      end
    end
  end
end