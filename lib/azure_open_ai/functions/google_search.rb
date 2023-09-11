module AzureOpenAi
  module Functions
    class GoogleSearch < Base
      def self.search_client
        return @search_client if @search_client.present?

        @search_client = GoogleCustomSearch.new
        @search_client
      end

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Googleから検索します。".to_en,
          parameters: {
            type: :object,
            properties: {
              search_word: {
                type: :string,
                description: "検索文字列を指定します。".to_en,
              },
            },
            required: [:search_word],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        search_results = self.class.search_client.search(args[:search_word], gl: 'jp')
        ret = search_results.items.map do |item|
          {
            title: item.title,
            url: item.formatted_url,
            snippet: item.html_snippet,
          }
        end

        ret
      end
    end
  end
end
