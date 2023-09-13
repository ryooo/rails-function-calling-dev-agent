module Llm
  module Functions
    class OverwriteFile < Base
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
              new_text: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.new_text"),
              },
            },
            required: [:filepath, :start_line_number, :end_line_number, :new_text],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        File.write(args[:filepath], args[:new_text])

        {result: :success}
      end
    end
  end
end
