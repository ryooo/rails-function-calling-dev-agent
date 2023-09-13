require 'rails_helper'

RSpec.describe Llm::Functions::ReadFile, type: :model do
  let(:read_file) { Llm::Functions::ReadFile.new }

  describe '#execute_and_generate_message' do
    context 'when the file exists' do
      let(:filepath) { 'app/controllers/application_controller.rb' }
      let(:expected_result) { { filepath: filepath, file_contents: File.read(filepath) } }

      it 'returns the contents of the file' do
        expect(read_file.execute_and_generate_message({ filepath: filepath })).to eq expected_result
      end
    end

    context 'when the file does not exist' do
      let(:filepath) { 'non_existent_file.rb' }
      let(:expected_result) { { filepath: filepath, error: 'File not found.' } }

      it 'returns an error message' do
        expect(read_file.execute_and_generate_message({ filepath: filepath })).to eq expected_result
      end
    end
  end
end