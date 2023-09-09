module AzureOpenAi
  module Functions
    class OpenUrl < Base
      def initialize(prompt)
        @prompt = prompt
      end

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Get html contents on the page.",
          parameters: {
            type: :object,
            properties: {
              url: {
                type: :string,
                description: "The page url.",
              },
            },
            required: [:url],
          },
        }
        @definition
      end

      def execute_and_generate_message(response_message)
        args = JSON.load(response_message['function_call']['arguments']) || {}
        puts("#{self.class} - #{args}")

        charset = nil
        html = URI.open(Addressable::URI.parse(args['url']).display_uri.to_s) do |f|
          charset = f.charset
          f.read
        end
        page = Nokogiri::HTML.parse(html, nil, charset)
        html_page = HTMLPage.new(contents: (page.at_css('body').send(:inner_html) || page.inner_html))
        page_contents = html_page.markdown
        if page_contents.size > 25_000
          splitter = Baran::MarkdownSplitter.new(chunk_size: 25_000, chunk_overlap: 128)
          chunks = splitter.chunks(page_contents)

          summaries = []
          azure_open_ai = AzureOpenAi::Client.new
          chunks.each do |chunk|
            ret = azure_open_ai.chat(parameters: {
              messages: [
                {
                  role: "system",
                  content: "Extract useful information from the message given by the user to the prompt \"#{@prompt}\"." + \
                             "User is japanese, so keep information is japanese.",
                },
                {
                  role: "user",
                  content: chunk[:text],
                },
              ],
            })
            summaries << ret.dig("choices", 0, "message", "content")
          end
          page_contents = summaries.join("\n\n")
        end

        {
          role: "function",
          name: self.function_name,
          content: JSON.dump({
                               url: args['url'],
                               title: page.title,
                               page_content: page_contents,
                             }),
        }
      end
    end
  end
end
