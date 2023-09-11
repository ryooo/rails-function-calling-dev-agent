module AzureOpenAi
  module Functions
    class AppendTextToFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "ファイルに文字列を挿入します。".to_en,
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "ファイルパスを指定します。".to_en,
              },
              line_number: {
                type: :number,
                description: "挿入する行番号を指定します。行番号は1から始まり、0やマイナスの値は使えません。".to_en,
              },
              append_text: {
                type: :string,
                description: "挿入する文字列を指定します。".to_en,
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
