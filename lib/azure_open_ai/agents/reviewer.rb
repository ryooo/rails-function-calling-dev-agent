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
        message_container.add_system_message("You are an excellent Ruby program reviewer. \n" + \
          "We review and thoroughly check the modifications made by programmers in response to requests from engineer leader, " + \
          "and identify any points that require additional attention and point them out to programmers in japanese.\n" + \
          "If you don't understand something, use google_search or open_url to find hints.\n" + \
          "When reviewing, please pay particular attention to the following points:\n" + \
          "- When adding a gem, also modify the Gemfile to ensure that bundle install passes.\n" + \
          "- The revised code should have a natural design, with readable code that utilizes appropriate and understandable variable names.\n" + \
          "- Rspec tests are implemented for Ruby scripts.\n" + \
          "- When modifying ci, the program executed by ci should work properly.\n" + \
          "- rspec works properly when modifying ruby　files.\n" + \
          "Once all checks have been completed and there are no issues found, execute the report_lgtm function surely.\n" + \
          "The request from the engineer leader is as follows.\n\n" + @leader_comment)
        if programmer_comment.present?
          message_container.add_system_message("The request from the programmer is as follows.\n\n" + programmer_comment)
        end

        diff = self.get_current_diff
        message_container.add_system_message("The modifications made by the programmer are as follows.\n\n" + diff)

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
            AzureOpenAi::Functions::OpenUrl.new(@leader_comment),
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