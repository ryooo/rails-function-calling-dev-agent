module Llm
  module Functions
    class ReadFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.filepath"),
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
