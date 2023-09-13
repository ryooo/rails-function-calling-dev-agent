module Llm
  module Functions
    class AppendTextToFile < Base
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
              line_number: {
                type: :number,
                description: I18n.t("functions.#{self.function_name}.parameters.line_number"),
              },
              append_text: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.append_text"),
              },
            },
            required: [:filepath, :line_number, :append_text],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        original_content = File.read(args[:filepath]).split("\n")
        line_number = args[:line_number].to_i - 1
        new_content = original_content[...line_number] + [args[:append_text]] + original_content[line_number..]
        File.write(args[:filepath], new_content.join("\n"))

        {after_append: File.read(args[:filepath])}
      end
    end
  end
end
