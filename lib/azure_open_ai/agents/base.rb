module AzureOpenAi
  module Agents
    class Base
      def initialize(leader_comment, color)
        @leader_comment = leader_comment
        @color = color
      end

      def actor_name
        self.class.name.split('::').last
      end

      def get_current_diff
        Open3.capture3('git add .')
        stdout, _, _ = Open3.capture3('git diff --staged')
        Open3.capture3('git reset .')
        stdout
      end

      def exec_sh(command)
        puts(command)
        stdout, stderr, status = Open3.capture3(command)
        if stdout.present?
          puts(stdout)
        end
        if stderr.present?
          puts(stderr.green)
        end
        if status.exitstatus != 0
          raise "Failed to execute #{command}"
        end
      end
    end
  end
end