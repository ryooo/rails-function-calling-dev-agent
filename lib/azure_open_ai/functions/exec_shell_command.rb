module AzureOpenAi
  module Functions
    class ExecShellCommand < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Execute shell command for test it.",
          parameters: {
            type: :object,
            properties: {
              script: {
                type: :string,
                description: "Program to run with shell.",
              },
            },
            required: [:script],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        stdout, stderr, status = Open3.capture3(args[:script])

        {stdout:, stderr:, exit_status: status.exitstatus}
      end
    end
  end
end
