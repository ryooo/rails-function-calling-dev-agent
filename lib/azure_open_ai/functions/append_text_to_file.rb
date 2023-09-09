module AzureOpenAi
  module Functions
    class AppendTextToFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Append text to file.",
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "Specify the path of the file to append." + \
                  "If the directory does not exist, it will be created automatically.",
              },
              line_number: {
                type: :number,
                description: "Specify the line number(starting from 1) to append. line number must > 0.",
              },
              append_text: {
                type: :string,
                description: "Specify the content to be added.",
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
