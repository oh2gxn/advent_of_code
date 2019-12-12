# frozen_string_literal: true

require 'csv'
require_relative '../amplification'

RSpec.describe AmplifierCascade do
  let :amps { described_class.new(program, phases, $stdout, feedback) }

  context 'with test program 1' do
    let :program { [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0] } # outputs ram[15]

    context 'with phases 4,3,2,1,0' do
      let :phases { ['4', '3', '2', '1', '0'] }
      let :feedback { false }

      it 'outputs 43210' do
        allow($stdout).to receive(:puts).with('43210')
        expect(amps.run(15)).to eq(43210)
      end
    end
  end

  context 'with test program 2' do
    let :program { [3,23,3,24,1002,24,10,24,1002,23,-1,23,
                    101,5,23,23,1,24,23,23,4,23,99,0,0] } # outputs ram[23]

    context 'with phases 0,1,2,3,4' do
      let :phases { ['0', '1', '2', '3', '4'] }
      let :feedback { false }

      it 'outputs 54321' do
        allow($stdout).to receive(:puts).with('54321')
        expect(amps.run(23)).to eq(54321)
      end
    end
  end

  context 'with test program 3' do
    let :program { [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
                    1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0] } # outputs ram[31]

    context 'with phases 1,0,4,3,2' do
      let :phases { ['1', '0', '4', '3', '2'] }
      let :feedback { false }

      it 'outputs 65210' do
        allow($stdout).to receive(:puts).with('65210')
        expect(amps.run(31)).to eq(65210)
      end
    end
  end

  context 'with test program 4' do
    let :program { [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
                    27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5] } # outputs ram[27], reads more input 5 times

    context 'with a single amp in phase 5' do
      let :phases { ['5'] }
      let :feedback { true }

      it 'outputs 1,3,7,15,31' do
        allow($stdout).to receive(:puts).with('1').and_return(nil)
        allow($stdout).to receive(:puts).with('3').and_return(nil)
        allow($stdout).to receive(:puts).with('7').and_return(nil)
        allow($stdout).to receive(:puts).with('15').and_return(nil)
        allow($stdout).to receive(:puts).with('31').and_return(nil)
        expect(amps.run(27)).to eq(31)
      end
    end

    context 'with phases 9,8,7,6,5' do
      let :phases { ['9', '8', '7', '6', '5'] }
      let :feedback { true }

      it 'outputs 139629729' do
        # NOTE: these have to be correct, or the test hangs
        allow($stdout).to receive(:puts).with('129').and_return(nil)
        allow($stdout).to receive(:puts).with('4257').and_return(nil)
        allow($stdout).to receive(:puts).with('136353').and_return(nil)
        allow($stdout).to receive(:puts).with('4363425').and_return(nil)
        allow($stdout).to receive(:puts).with('139629729').and_return(nil)
        expect(amps.run(27)).to eq(139629729)
      end
    end
  end

  context 'with test program 5' do
    let :program { [3,52,
                    1001,52,-5,52,
                    3,53,
                    1,52,56,54,
                    1007,54,5,55,
                    1005,55,26,
                    1001,54,-5,54,
                    1105,1,12,
                    1,53,54,53,
                    1008,54,0,55,
                    1001,55,1,55,
                    2,53,55,53,
                    4,53,
                    1001,56,-1,56,
                    1005,56,6,
                    99,
                    0,0,0,0,10] } # outputs ram[53], reads more input 10 times

    context 'with a single amp in phase 5' do
      let :phases { ['5'] }
      let :feedback { true }

      it 'outputs 1,3,7,15,31' do
        allow($stdout).to receive(:puts).with('0').and_return(nil)
        allow($stdout).to receive(:puts).with('4').and_return(nil)
        allow($stdout).to receive(:puts).with('7').and_return(nil)
        allow($stdout).to receive(:puts).with('9').and_return(nil)
        allow($stdout).to receive(:puts).with('10').and_return(nil)
        allow($stdout).to receive(:puts).with('20').and_return(nil)
        allow($stdout).to receive(:puts).with('24').and_return(nil)
        allow($stdout).to receive(:puts).with('27').and_return(nil)
        allow($stdout).to receive(:puts).with('29').and_return(nil)
        allow($stdout).to receive(:puts).with('30').and_return(nil)
        expect(amps.run(53)).to eq(30)
      end
    end

    context 'with phases 9,7,8,5,6' do
      let :phases { ['9', '7', '8', '5', '6'] }
      let :feedback { true }

      it 'outputs 18216' do
        # NOTE: these have to be correct, or the test hangs
        allow($stdout).to receive(:puts).with('19').and_return(nil)
        allow($stdout).to receive(:puts).with('58').and_return(nil)
        allow($stdout).to receive(:puts).with('128').and_return(nil)
        allow($stdout).to receive(:puts).with('271').and_return(nil)
        allow($stdout).to receive(:puts).with('552').and_return(nil)
        allow($stdout).to receive(:puts).with('1123').and_return(nil)
        allow($stdout).to receive(:puts).with('2266').and_return(nil)
        allow($stdout).to receive(:puts).with('4544').and_return(nil)
        allow($stdout).to receive(:puts).with('9103').and_return(nil)
        allow($stdout).to receive(:puts).with('18216').and_return(nil)
        expect(amps.run(53)).to eq(18216)
      end
    end
  end
end
