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

  context 'with immediate value multiplication example' do
    let :memory_dump { [1002,4,3,4,33] }

    it 'returns 99 at 4' do
      expect(subject.run(4)).to eq(99)
    end
  end

  context 'with negative immediate value addition example' do
    let :memory_dump { [1101,100,-1,4,0] }

    it 'returns 99 at 4' do
      # shits its pants if it doesn't
      expect(subject.run(4)).to eq(99)
    end
  end

  context 'with position mode equals comparison example' do
    let :memory_dump { [3,9,8,9,10,9,4,9,99,-1,8] }

    context 'given 8 as input' do
      before { allow($stdin).to receive(:gets).and_return('8') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(9)).to eq(1)
      end
    end

    context 'given 42 as input' do
      before { allow($stdin).to receive(:gets).and_return('42') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(9)).to eq(0)
      end
    end
  end

  context 'with position mode less than comparison example' do
    let :memory_dump { [3,9,7,9,10,9,4,9,99,-1,8] }

    context 'given 7 as input' do
      before { allow($stdin).to receive(:gets).and_return('7') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(9)).to eq(1)
      end
    end

    context 'given 8 as input' do
      before { allow($stdin).to receive(:gets).and_return('8') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(9)).to eq(0)
      end
    end
  end

  context 'with immediate mode equals comparison example' do
    let :memory_dump { [3,3,1108,-1,8,3,4,3,99] }

    context 'given 8 as input' do
      before { allow($stdin).to receive(:gets).and_return('8') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(3)).to eq(1)
      end
    end

    context 'given 42 as input' do
      before { allow($stdin).to receive(:gets).and_return('42') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(3)).to eq(0)
      end
    end
  end

  context 'with immediate mode less than comparison example' do
    let :memory_dump { [3,3,1107,-1,8,3,4,3,99] }

    context 'given 7 as input' do
      before { allow($stdin).to receive(:gets).and_return('7') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(3)).to eq(1)
      end
    end

    context 'given 8 as input' do
      before { allow($stdin).to receive(:gets).and_return('8') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(3)).to eq(0)
      end
    end
  end

  context 'with position mode jump example' do
    let :memory_dump { [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9] }

    context 'given 42 as input' do
      before { allow($stdin).to receive(:gets).and_return('42') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(13)).to eq(1)
      end
    end

    context 'given 0 as input' do
      before { allow($stdin).to receive(:gets).and_return('0') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(13)).to eq(0)
      end
    end
  end

  context 'with immediate mode jump example' do
    let :memory_dump { [3,3,1105,-1,9,1101,0,0,12,4,12,99,1] }

    context 'given 42 as input' do
      before { allow($stdin).to receive(:gets).and_return('42') }

      it 'outputs 1' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1')
        expect(subject.run(12)).to eq(1)
      end
    end

    context 'given 0 as input' do
      before { allow($stdin).to receive(:gets).and_return('0') }

      it 'outputs 0' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('0')
        expect(subject.run(12)).to eq(0)
      end
    end
  end

  context 'with larger comparison example' do
    let :memory_dump do
      [3,21, # input = gets.to_i
       1008,21,8,20, # cr = input==8
       1005,20,22, # 22 if cr
       107,8,21,20, # cr = 8 < input
       1006,20,31, # 31 unless cr
       1106,0,36, # 36 if true
       98,
       0, # 20, comparison result or output
       0, # 21, input
       1002,21,125,20, # 22, output = input*125
       4,20, # puts output, which is 1000
       1105,1,46, # 46 if true
       104,999, # 31, puts 999
       1105,1,46, # 46 if true
       1101,1000,1,20, # 36, output = 1000+1
       4,20, # puts output, which is 1001
       1105,1,46, # 46 if true
       98,
       99] # 46
    end

    context 'given 7 as input' do
      before { allow($stdin).to receive(:gets).and_return('7') }

      it 'outputs 999 in immediate mode' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('999')
        expect(subject.run(46)).to eq(99) # just output, not writing it down
      end
    end

    context 'given 8 as input' do
      before { allow($stdin).to receive(:gets).and_return('8') }

      it 'outputs 1000' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1000')
        expect(subject.run(20)).to eq(1000)
      end
    end

    context 'given 9 as input' do
      before { allow($stdin).to receive(:gets).and_return('9') }

      it 'outputs 1001' do
        allow($stdout).to receive(:print).with(described_class::PROMPT)
        allow($stdout).to receive(:puts).with('1001')
        expect(subject.run(20)).to eq(1001)
      end
    end
  end
end  
