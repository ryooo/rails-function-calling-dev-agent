module AzureOpenAi
  module Functions
    class OpenUrl < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "HTMLの内容を取得します。".to_en,
          parameters: {
            type: :object,
            properties: {
              url: {
                type: :string,
                description: "HTMLを取得するURLを指定します。".to_en,
              },
              what_i_want_to_know: {
                type: :string,
                description: "具体的に知りたい内容について指定します。".to_en,
              },
            },
            required: [:url, :what_i_want_to_know],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)

        charset = nil
        html = URI.open(Addressable::URI.parse(args[:url]).display_uri.to_s) do |f|
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
                  content: ("ユーザーから送られるのはあるウェブページの内容です。" + \
                    "この中からユーザーが知りたい内容と照らして有益な情報を抽出してください。" + \
                    "ユーザーが知りたい内容は以下です。").to_en + "\n#{@purpose.wrap_as_markdown}",
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
          url: args[:url],
          title: page.title,
          page_content: page_contents,
        }
      end
    end
  end
end
