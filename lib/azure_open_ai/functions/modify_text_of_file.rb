module AzureOpenAi
  module Functions
    class ModifyTextOfFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Delete text of file.",
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "Specify the path of the file to append." + \
                  "If the directory does not exist, it will be created automatically.",
              },
              start_line_number: {
                type: :number,
                description: "Starting line number(starting from 1) of range to delete. line number must > 0.",
              },
              end_line_number: {
                type: :number,
                description: "End line number(starting from 1) of the range to delete. line number must > 0.",
              },
              new_text: {
                type: :string,
                description: "Specify the content to overwrite.",
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
