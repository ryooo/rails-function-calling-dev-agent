module AzureOpenAi
  module Functions
    class ExecRspecTest < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              file_or_dir_path: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.file_or_dir_path"),
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
