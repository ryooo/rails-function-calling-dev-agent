require 'rails_helper'

RSpec.describe Llm::Functions::OpenUrl do
  describe '#execute_and_generate_message' do
    context 'when the url is valid' do
      let(:url) { 'https://www.google.co.jp/' }
      let(:what_i_want_to_know) { 'title' }

      it 'returns the correct result' do
        result = described_class.new.execute_and_generate_message({ url: url, what_i_want_to_know: what_i_want_to_know })

        expect(result[:url]).to eq url
        expect(result[:title]).not_to be_nil
        expect(result[:page_content]).not_to be_nil
      end
    end

    context 'when the url is invalid' do
      let(:url) { 'invalid_url' }
      let(:what_i_want_to_know) { 'title' }

      it 'raises an error' do
        expect {
          described_class.new.execute_and_generate_message({ url: url, what_i_want_to_know: what_i_want_to_know })
        }.to raise_error(Addressable::URI::InvalidURIError)
      end
    end
  end
end
