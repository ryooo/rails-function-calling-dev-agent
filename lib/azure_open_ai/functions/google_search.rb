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
          description: "Google search, fetch real-time data. " + \
                         "Never abbreviate returned URLs and pay attention keeping accuracy.",
          parameters: {
            type: :object,
            properties: {
              search_word: {
                type: :string,
                description: "The search query.",
              },
            },
            required: [:search_word],
          },
        }
        @definition
      end

      def execute_and_generate_message(response_message)
        args = JSON.load(response_message['function_call']['arguments']) || {}
        puts("#{self.class} - #{args}")
        search_results = self.class.search_client.search(args['search_word'], gl: 'jp')
        search_results_hash = []
        search_results.items.each do |item|
          search_results_hash << {
            title: item.title,
            url: item.formatted_url,
            snippet: item.html_snippet,
          }
        end
        {
          role: "function",
          name: self.function_name,
          content: JSON.dump(search_results_hash),
        }
      end
    end
  end
end
