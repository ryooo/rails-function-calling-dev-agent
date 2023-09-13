require 'rails_helper'

RSpec.describe Llm::Functions::AppendTextToFile, type: :model do
  let(:filepath) { 'spec/llm/functions/dummy_file.txt' }
  let(:append_text) { 'This is a test.' }

  before do
    File.write(filepath, 'Original text.')
  end

  after do
    File.delete(filepath) if File.exist?(filepath)
  end

  describe '#execute_and_generate_message' do
    subject { described_class.new.execute_and_generate_message(filepath: filepath, append_text: append_text) }

    it 'appends text to the file' do
      expect { subject }.to change { File.read(filepath).chomp }.from('Original text.').to('Original text.This is a test.')
    end

    it 'returns a success result' do
      expect(subject).to eq({ result: :success })
    end
  end
end