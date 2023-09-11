module AzureOpenAi
  module Functions
    class MakeNewFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "新しいファイルを作成します。".to_en,
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "ファイルパスを指定します。ディレクトリが存在しない場合は、ディレクトリを作成します。".to_en,
              },
              file_contents: {
                type: :string,
                description: "ファイルの内容を指定します。".to_en,
              },
            },
            required: [:filepath, :file_contents],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        dirname = File.dirname(args[:filepath])
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end
        File.write(args[:filepath], args[:file_contents])

        {result: "success"}
      end
    end
  end
end
