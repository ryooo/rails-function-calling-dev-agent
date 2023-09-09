require 'rails_helper'

RSpec.describe AzureOpenAi::Functions::ReadFile, type: :model do
  describe '#execute_and_generate_message' do
    context 'when the file exists' do
      it 'returns the file contents' do
        filepath = 'app/controllers/application_controller.rb'
        result = described_class.new.execute_and_generate_message(filepath: filepath)
        expect(result[:filepath]).to eq(filepath)
        expect(result[:file_contents]).not_to be_nil
      end
    end

    context 'when the file does not exist' do
      it 'returns an error' do
        filepath = 'non_existent_file.rb'
        result = described_class.new.execute_and_generate_message(filepath: filepath)
        expect(result[:filepath]).to eq(filepath)
        expect(result[:error]).to eq('File not found.')
      end
    end
  end
end
