module Llm
  module Functions
    class MakeNewFile < Base
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
              file_contents: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.file_contents"),
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
