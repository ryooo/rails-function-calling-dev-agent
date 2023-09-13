require 'rails_helper'

RSpec.describe Llm::Functions::GoogleSearch, type: :model do
  let(:google_search) { Llm::Functions::GoogleSearch.new }
  let(:search_word) { 'Ruby programming' }
  let(:mock_search_client) { double('GoogleCustomSearch') }

  before do
    allow(Llm::Functions::GoogleSearch).to receive(:search_client).and_return(mock_search_client)
  end

  describe '#execute_and_generate_message' do
    context 'when the search returns results' do
      let(:search_results) { double('SearchResults') }
      let(:items) do
        [
          double('Item', title: 'Ruby Programming', formatted_url: 'https://www.ruby-lang.org/en/', html_snippet: 'A dynamic, open source programming language with a focus on simplicity and productivity.'),
          double('Item', title: 'Ruby (programming language) - Wikipedia', formatted_url: 'https://en.wikipedia.org/wiki/Ruby_(programming_language)', html_snippet: 'Ruby is a high-level general-purpose programming language.')
        ]
      end

      before do
        allow(mock_search_client).to receive(:search).with(search_word, gl: 'jp').and_return(search_results)
        allow(search_results).to receive(:items).and_return(items)
      end

      it 'returns search results' do
        expected_result = items.map do |item|
          {
            title: item.title,
            url: item.formatted_url,
            snippet: item.html_snippet,
          }
        end

        expect(google_search.execute_and_generate_message({ search_word: search_word })).to eq expected_result
      end
    end

    context 'when the search does not return results' do
      let(:search_results) { double('SearchResults', items: []) }

      before do
        allow(mock_search_client).to receive(:search).with(search_word, gl: 'jp').and_return(search_results)
      end

      it 'returns an empty array' do
        expect(google_search.execute_and_generate_message({ search_word: search_word })).to eq []
      end
    end
  end
end