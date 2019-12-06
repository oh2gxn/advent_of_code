# frozen_string_literal: true

require_relative '../int_code'

RSpec.describe IntCode do
  let :subject { described_class.new(memory_dump) }

  context 'with the sum 1+1 example' do
    let :memory_dump { [1,0,0,0,99] }
    it 'returns 2' do
      expect(subject.run(0)).to eq(2)
    end
  end

  context 'with the multiply 2*3 example' do
    let :memory_dump { [2,3,0,3,99] }
    it 'returns 6' do
      expect(subject.run(3)).to eq(6)
    end
  end

  context 'with the multiply 99*99 example' do
    let :memory_dump { [2,4,4,5,99,0] }
    it 'returns 9801' do
      expect(subject.run(5)).to eq(9801)
    end
  end

  context 'with the bigger example' do
    let :memory_dump { [1,1,1,4,99,5,6,0,99] }
    it 'returns 30 at 0' do
      expect(subject.run(0)).to eq(30)
    end

    it 'returns 2 at 4' do
      expect(subject.run(4)).to eq(2)
    end
  end

  context 'with the echo example' do
    let :memory_dump { [3,0,4,0,99] }

    context 'given 42 as input' do
      before { allow($stdin).to receive(:gets).and_return('42') }
      
      it 'outputs 42' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('42')
        expect(subject.run(0)).to eq(42)
      end
    end
  end
end  
