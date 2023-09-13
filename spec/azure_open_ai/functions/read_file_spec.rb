require 'rails_helper'

RSpec.describe AzureOpenAi::Functions::ReadFile, type: :model do
  describe 'execute_and_generate_message' do
    context 'when file exists' do
      let(:filepath) { 'spec/dummy_files/dummy.txt' }
      before do
        File.open(filepath, 'w') { |file| file.write('Hello, World!') }
      end

      it 'returns the file contents' do
        result = AzureOpenAi::Functions::ReadFile.new.execute_and_generate_message({ filepath: filepath })
        expect(result[:file_contents]).to eq('Hello, World!')
      end

      after do
        File.delete(filepath)
      end
    end

    context 'when file does not exist' do
      let(:filepath) { 'spec/dummy_files/non_existent.txt' }

      it 'returns an error' do
        result = AzureOpenAi::Functions::ReadFile.new.execute_and_generate_message({ filepath: filepath })
        expect(result[:error]).to eq('File not found.')
      end
    end
  end
end