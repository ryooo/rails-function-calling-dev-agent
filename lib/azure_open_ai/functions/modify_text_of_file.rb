module AzureOpenAi
  module Functions
    class ModifyTextOfFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "ファイルの文字列を修正して、修正後のファイル内容を返します。".to_en,
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "ファイルパスを指定します。".to_en,
              },
              start_line_number: {
                type: :number,
                description: "上書きする範囲の先頭の行番号を指定します。行番号は1から始まり、0やマイナスの値は使えません。".to_en,
              },
              end_line_number: {
                type: :number,
                description: "上書きする範囲の最終の行番号を指定します。行番号は1から始まり、0やマイナスの値は使えません。".to_en,
              },
              new_text: {
                type: :string,
                description: "上書き後の文字列を指定します。".to_en,
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
