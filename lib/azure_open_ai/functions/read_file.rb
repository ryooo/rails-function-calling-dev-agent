module AzureOpenAi
  module Functions
    class ReadFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Get the file contents.",
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "The file path to read.",
              },
            },
            required: [:filepath],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        if File.exist?(args[:filepath])
          {
            filepath: args[:filepath],
            file_contents: File.read(args[:filepath]),
          }
        else
          {
            filepath: args[:filepath],
            error: "File not found.",
          }
        end
      end
    end
  end
end
