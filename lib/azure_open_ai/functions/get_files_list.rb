module AzureOpenAi
  module Functions
    class GetFilesList < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Get the file list of this repository.",
          parameters: {
            type: :object,
            properties: {},
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        files_list = Dir.glob("**/*.{rb,yml}")

        {files_list:}
      end
    end
  end
end
