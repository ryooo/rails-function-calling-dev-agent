module Llm
  module Functions
    class GeneratePullRequestParams < Base
      attr_reader :title, :description, :branch_name

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              title: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.title"),
              },
              description: {
                type: :number,
                description: I18n.t("functions.#{self.function_name}.parameters.description"),
              },
              branch_name: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.branch_name"),
              },
            },
            required: [:title, :description, :branch_name],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        @title = args[:title]
        @description = args[:description]
        @branch_name = args[:branch_name]

        {result: 'success'}
      end
    end
  end
end
