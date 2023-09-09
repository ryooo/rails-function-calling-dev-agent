module AzureOpenAi
  module Functions
    class GeneratePrInfo < Base
      attr_reader :title, :description, :branch_name

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Generate information for create pull request.",
          parameters: {
            type: :object,
            properties: {
              title: {
                type: :string,
                description: "Specify the title of the pull request.",
              },
              description: {
                type: :number,
                description: "Specify the description of the pull request.",
              },
              branch_name: {
                type: :string,
                description: "Specify the branch_name.",
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
