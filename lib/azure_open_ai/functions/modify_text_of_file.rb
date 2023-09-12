module AzureOpenAi
  module Functions
    class ModifyTextOfFile < Base
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
              start_line_number: {
                type: :number,
                description: I18n.t("functions.#{self.function_name}.parameters.start_line_number"),
              },
              end_line_number: {
                type: :number,
                description: I18n.t("functions.#{self.function_name}.parameters.end_line_number"),
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
        original_content = File.read(args[:filepath]).split("\n")
        start_line_number = args[:start_line_number].to_i - 1
        end_line_number = args[:end_line_number].to_i
        new_content = original_content[...start_line_number] + [args[:new_text]] + original_content[end_line_number..]
        File.write(args[:filepath], new_content.join("\n"))

        {after_modified: File.read(args[:filepath])}
      end
    end
  end
end
