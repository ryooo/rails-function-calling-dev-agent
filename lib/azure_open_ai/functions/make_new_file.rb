module AzureOpenAi
  module Functions
    class MakeNewFile < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "make new file.",
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: "Specify the path of the new file." + \
                  "If the directory does not exist, it will be created automatically.",
              },
              file_contents: {
                type: :string,
                description: "The content of file.",
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
