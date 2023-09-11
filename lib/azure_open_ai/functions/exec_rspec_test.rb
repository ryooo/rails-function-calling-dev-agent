module AzureOpenAi
  module Functions
    class ExecRspecTest < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Execute rspec test for specified spec file prefix.",
          parameters: {
            type: :object,
            properties: {
              file_or_dir_path: {
                type: :string,
                description: "Specify the file path of the spec file to be executed. " + \
                  "If you specify a directory path, all tests in the directory will be executed.",
              },
            },
            required: [:file_or_dir_path],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        script = "bundle exec rspec '#{args['file_or_dir_path']}'"
        stdout, stderr, status = Open3.capture3(script)

        {stdout:, stderr:, exit_status: status.exitstatus}
      end
    end
  end
end
