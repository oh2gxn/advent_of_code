# frozen_string_literal: true

require 'csv'
require_relative '../amplification'

RSpec.describe ForkedIO do
  let :output { described_class.new(output1, output2) }

  context 'when writing to both stdout and stderr' do
    let :output1 { $stdout }
    let :output2 { $stderr }
    let :content { 'FOO' }
    subject { output.puts(content) }

    it 'calls both outputs' do
      allow($stdout).to receive(:puts).with(content)
      allow($stderr).to receive(:puts).with(content)
      expect(subject).to be_nil
    end
  end
end
