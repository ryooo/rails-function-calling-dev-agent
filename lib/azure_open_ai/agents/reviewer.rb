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
        message_container.add_system_message(I18n.t('agents.reviewer.system', comment: @leader_comment))
        if programmer_comment.present?
          message_container.add_system_message(I18n.t('agents.reviewer.programmer_comment', comment: programmer_comment))
        end

        diff = self.get_current_diff
        message_container.add_system_message(I18n.t('agents.reviewer.diff', diff:))

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