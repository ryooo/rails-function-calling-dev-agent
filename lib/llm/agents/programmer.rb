module Llm
  module Agents
    class Programmer < Base
      def work(reviewer_comment: nil)
        puts("---------------------------------".send(@color))
        puts("#{self.actor_name}: start to work".send(@color))

        message_container = LlmMessageContainer.new
        message_container.add_system_message(I18n.t('agents.programmer.system', comment: @leader_comment))
        if reviewer_comment.present?
          message_container.add_system_message(I18n.t('agents.programmer.reviewer_comment', comment: reviewer_comment))
        end

        if diff = self.get_current_diff
          message_container.add_system_message(I18n.t('agents.programmer.diff', diff:))
        end

        azure_open_ai = Llm::Client::AzureOpenAi.new
        io, _, _ = azure_open_ai.chat_with_function_calling_loop(
          messages: message_container,
          functions: [
            Llm::Functions::GetFilesList.new,
            Llm::Functions::ReadFile.new,
            Llm::Functions::OverwriteFile.new,
            Llm::Functions::MakeNewFile.new,

            Llm::Functions::ExecRspecTest.new,

            Llm::Functions::GoogleSearch.new,
            Llm::Functions::OpenUrl.new,
          ],
          color: @color,
          actor_name: self.actor_name,
        )

        comment = io.rewind && io.read
        puts("#{self.actor_name}: #{comment}".send(@color))
        comment
      end

      def make_pr!
        return if ENV['MAKE_PR'].blank?

        generate_pr_params_function = Llm::Functions::GeneratePullRequestParams.new
        azure_open_ai = Llm::Client::AzureOpenAi.new
        io, _, _ = azure_open_ai.chat_with_function_calling_loop(
          messages: [
            {
              role: :system,
              content: I18n.t('agents.programmer.diff', diff: self.get_current_diff),
            }
          ],
          functions: [generate_pr_params_function],
          color: @color,
          actor_name: self.actor_name,
        )
        issue_number = ENV['ISSUE_NUMBER'].blank? ? '' : " ##{ENV['ISSUE_NUMBER']}"
        issue_url = ENV['ISSUE_NUMBER'].blank? ? "" : "\n\n- https://github.com/ryooo/rails-function-calling-dev-agent/issues/#{ENV['ISSUE_NUMBER']}"
        exec_sh("git checkout -b #{generate_pr_params_function.branch_name}")
        exec_sh("git add .")
        exec_sh("git commit -m '#{generate_pr_params_function.title}'")
        exec_sh("git push --set-upstream origin #{generate_pr_params_function.branch_name}")
        exec_sh("gh pr create --base main --head #{generate_pr_params_function.branch_name} " + \
          "--title '#{generate_pr_params_function.title}#{issue_number}' --body '#{generate_pr_params_function.description}#{issue_url}'")
      end
    end
  end
end