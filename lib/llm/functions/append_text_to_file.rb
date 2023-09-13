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
              append_text: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.append_text"),
              },
            },
            required: [:filepath, :append_text],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        open(args[:filepath], 'a') { |f|
          f.puts args[:append_text]
        }

        {result: :success}
      end
    end
  end
end
