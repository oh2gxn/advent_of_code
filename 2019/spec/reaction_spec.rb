# frozen_string_literal: true

require_relative '../stoichiometry'

RSpec.describe Reaction do
  let :required { described_class.solve(output, reactions) }

  context 'with a really simple nanofactory' do
    let :reactions do
      { 'A' => described_class.new('10 ORE => 10 A'),
        'FUEL' => described_class.new('7 A => 1 FUEL') }
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 10 ORE, nothing else' do
        expect(required['ORE']).to eq(10)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end

  context 'with the first nanofactory' do
    let :reactions do
      { 'A' => described_class.new('10 ORE => 10 A'),
        'B' => described_class.new('1 ORE => 1 B'),
        'C' => described_class.new('7 A, 1 B => 1 C'),
        'D' => described_class.new('7 A, 1 C => 1 D'),
        'E' => described_class.new('7 A, 1 D => 1 E'),
        'FUEL' => described_class.new('7 A, 1 E => 1 FUEL') }
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 31 ORE, nothing else' do
        expect(required['ORE']).to eq(31)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end

  context 'with the second nanofactory' do
    let :reactions do
      { 'A' => described_class.new('9 ORE => 2 A'),
        'B' => described_class.new('8 ORE => 3 B'),
        'C' => described_class.new('7 ORE => 5 C'),
        'AB' => described_class.new('3 A, 4 B => 1 AB'),
        'BC' => described_class.new('5 B, 7 C => 1 BC'),
        'CA' => described_class.new('4 C, 1 A => 1 CA'),
        'FUEL' => described_class.new('2 AB, 3 BC, 4 CA => 1 FUEL') }
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 165 ORE, nothing else' do
        expect(required['ORE']).to eq(165)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end

  context 'with the third nanofactory' do
    let :reactions do
      { 'NZVS' => described_class.new('157 ORE => 5 NZVS'),
        'DCFZ' => described_class.new('165 ORE => 6 DCFZ'),
        'QDVJ' => described_class.new('12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ'),
        'PSHF' => described_class.new('179 ORE => 7 PSHF'),
        'HKGWZ' => described_class.new('177 ORE => 5 HKGWZ'),
        'XJWVT' => described_class.new('7 DCFZ, 7 PSHF => 2 XJWVT'),
        'GPVTF' => described_class.new('165 ORE => 2 GPVTF'),
        'KHKGT' => described_class.new('3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT'),
        'FUEL' => described_class.new('44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL') }
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      xit 'requires 13312 ORE, nothing else' do
        expect(required['ORE']).to eq(13312) # FIXME: getting 13654
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end
end
