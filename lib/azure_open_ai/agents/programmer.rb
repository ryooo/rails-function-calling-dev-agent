module AzureOpenAi
  module Agents
    class Programmer < Base
      def work(reviewer_comment: nil)
        puts("---------------------------------".send(@color))
        puts("#{self.actor_name}: start to work".send(@color))

        message_container = LlmMessageContainer.new
        message_container.add_system_message("You are an excellent Ruby programmer. \n" + \
          "Please make appropriate modifications to this repository using functions based on instructions from engineer leader.\n" + \
          "Once the modification is complete, " + \
          "use the Rails runner or shell command to confirm that the modification is as intended and complete.\n" + \
          "Students are responsible for determining program policies themselves.\n" + \
          "When implementing the test code, imagine the specification from the implementation of the target class and concretely implement the test case.\n" + \
          "And check the rspec results and modify them one by one to pass the tests.\n" + \
          "Basically, do not modify the implementation side.\n" + \
          "If implementation side include any bug, then modify the implementation side.\n" + \
          "All dummy files related to test should be created under the spec folder.\n" + \
          "When modifying a file, read_file first and indent properly.\n" + \
          "If you don't understand something, use google_search or open_url to find hints.\n" + \
          "You are the only programmer. Don't raise the issue with the reviewer while there is a problem;" + \
          "solve the problem before responding to the reviewer.\n" + \
          "After making the corrections, please inform the reviewer of your concerns in japanese.\n" + \
          "The request from the engineer leader is as follows.\n\n" + @leader_comment)
        if reviewer_comment.present?
          message_container.add_system_message("The request from the reviewer is as follows.\n\n" + reviewer_comment)
        end

        if diff = self.get_current_diff
          message_container.add_system_message("The current modifications are as follows.\n\n" + diff)
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

            AzureOpenAi::Functions::ExecRailsRunner.new,
            AzureOpenAi::Functions::ExecShellCommand.new,

            AzureOpenAi::Functions::GoogleSearch.new,
            AzureOpenAi::Functions::OpenUrl.new(@leader_comment),
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
        exec_sh("git checkout -b #{generate_pr_params_function.branch_name}")
        exec_sh("git add .")
        exec_sh("git commit -m '#{generate_pr_params_function.title}'")
        exec_sh("git push --set-upstream origin #{generate_pr_params_function.branch_name}")
        exec_sh("gh pr create --base main --head #{generate_pr_params_function.branch_name} " + \
          "--title '#{generate_pr_params_function.title}' --body '#{generate_pr_params_function.description}'")
      end
    end
  end
end