# frozen_string_literal: true

require 'csv'
require_relative '../amplification'

RSpec.describe AmplifierCascade do
  let :amps { described_class.new(program, phases, $stdout) }

  context 'with test program 1' do
    let :program { [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0] } # outputs ram[15]

    context 'with phases 4,3,2,1,0' do
      let :phases { ['4', '3', '2', '1', '0'] }

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

      it 'outputs 65210' do
        allow($stdout).to receive(:puts).with('65210')
        expect(amps.run(31)).to eq(65210)
      end
    end
  end
end
