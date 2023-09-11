module AzureOpenAi
  module Functions
    class GeneratePullRequestParams < Base
      attr_reader :title, :description, :branch_name

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Pull requestを作るためのパラメータを生成します。".to_en,
          parameters: {
            type: :object,
            properties: {
              title: {
                type: :string,
                description: "Pull requestのタイトルを指定します。".to_en,
              },
              description: {
                type: :number,
                description: "Pull requestの説明文を指定します。diffの詳細を日本語で説明して指定してください。".to_en,
              },
              branch_name: {
                type: :string,
                description: "Pull requestを作成する時のブランチ名を指定します。".to_en,
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
