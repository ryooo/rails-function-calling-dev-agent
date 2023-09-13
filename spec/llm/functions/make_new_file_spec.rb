require 'rails_helper'

RSpec.describe Llm::Functions::MakeNewFile, type: :model do
  describe '#execute_and_generate_message' do
    let(:filepath) { 'spec/dummy_files/test_file.txt' }
    let(:file_contents) { 'This is a test file.' }
    let(:args) { { filepath: filepath, file_contents: file_contents } }

    before do
      FileUtils.rm(filepath) if File.exist?(filepath)
    end

    after do
      FileUtils.rm(filepath) if File.exist?(filepath)
    end

    it 'creates a new file with specified contents' do
      expect(File.exist?(filepath)).to be false
      described_class.new.execute_and_generate_message(args)
      expect(File.exist?(filepath)).to be true
      expect(File.read(filepath)).to eq file_contents
    end

    context 'when the directory does not exist' do
      let(:filepath) { 'spec/dummy_files/non_existent_directory/test_file.txt' }

      before do
        FileUtils.rm_rf('spec/dummy_files/non_existent_directory') if Dir.exist?('spec/dummy_files/non_existent_directory')
      end

      it 'creates the directory and the file' do
        expect(File.exist?('spec/dummy_files/non_existent_directory')).to be false
        described_class.new.execute_and_generate_message(args)
        expect(File.exist?('spec/dummy_files/non_existent_directory')).to be true
        expect(File.exist?(filepath)).to be true
        expect(File.read(filepath)).to eq file_contents
      end
    end
  end
end