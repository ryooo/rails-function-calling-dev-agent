module AzureOpenAi
  module Functions
    class ExecRailsRunner < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Execute rails runner command for test it.",
          parameters: {
            type: :object,
            properties: {
              script: {
                type: :string,
                description: "Program to run with rails runner.",
              },
            },
            required: [:script],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        script = "bundle exec rails runner '#{args['script']}'"
        stdout, stderr, status = Open3.capture3(script)

        {stdout:, stderr:, exit_status: status.exitstatus}
      end
    end
  end
end
