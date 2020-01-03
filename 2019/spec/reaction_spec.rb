# frozen_string_literal: true

require_relative '../stoichiometry'

RSpec.describe Reaction do
  let :required { described_class.solve(output, reactions) }

  context 'with a really simple nanofactory' do
    let :reactions do
      { 'A' => described_class.new('10 ORE => 10 A'),
        'FUEL' => described_class.new('7 A => 1 FUEL') }
    end
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
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
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
    end

    context 'when given priorities' do

      it 'will assign priorities' do
        expect(reactions.values.map(&:level)).to all( be_an(Integer) )
      end

      it 'will assign FUEL the top priority' do
        expect(reactions['FUEL'].level).to eq(0)
      end

      it 'will assign E higher priority than A' do
        expect(reactions['E'].level < reactions['A'].level).to be true
      end

      it 'will assign C higher priority than A' do
        expect(reactions['C'].level < reactions['A'].level).to be true
      end

      it 'will sort by priority' do
        sorted_keys = described_class.sort_by_level(reactions, reactions.keys)
        expect(sorted_keys).to contain_exactly('A', 'B', 'C', 'D', 'E', 'FUEL')
      end
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
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
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
      {
        'NZVS' => described_class.new('157 ORE => 5 NZVS'),
        'DCFZ' => described_class.new('165 ORE => 6 DCFZ'),
        'FUEL' => described_class.new('44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL'),
        'QDVJ' => described_class.new('12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ'),
        'PSHF' => described_class.new('179 ORE => 7 PSHF'),
        'HKGWZ' => described_class.new('177 ORE => 5 HKGWZ'),
        'XJWVT' => described_class.new('7 DCFZ, 7 PSHF => 2 XJWVT'),
        'GPVTF' => described_class.new('165 ORE => 2 GPVTF'),
        'KHKGT' => described_class.new('3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT')
      }
    end
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 13312 ORE, nothing else' do
        expect(required['ORE']).to eq(13312)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end

  context 'with the fourth nanofactory' do
    let :reactions do
      {
        'STKFG' => described_class.new('2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG'),
        'VPVL' => described_class.new('17 NVRVD, 3 JNWZP => 8 VPVL'),
        'FUEL' => described_class.new('53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL'),
        'FWMGM' => described_class.new('22 VJHF, 37 MNCFX => 5 FWMGM'),
        'NVRVD' => described_class.new('139 ORE => 4 NVRVD'),
        'JNWZP' => described_class.new('144 ORE => 7 JNWZP'),
        'HVMC' => described_class.new('5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC'),
        'GNMV' => described_class.new('5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV'),
        'MNCFX' => described_class.new('145 ORE => 6 MNCFX'),
        'CXFTF' => described_class.new('1 NVRVD => 8 CXFTF'),
        'RFSQX' => described_class.new('1 VJHF, 6 MNCFX => 4 RFSQX'),
        'VJHF' => described_class.new('176 ORE => 6 VJHF')
      }
    end
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 180697 ORE, nothing else' do
        expect(required['ORE']).to eq(180697)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end

  context 'with the fifth nanofactory' do
    let :reactions do
      {
        'CNZTR' => described_class.new('171 ORE => 8 CNZTR'),
        'PLWSL' => described_class.new('7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL'),
        'BHXH' => described_class.new('114 ORE => 4 BHXH'),
        'BMBT' => described_class.new('14 VRPVC => 6 BMBT'),
        'FUEL' => described_class.new('6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL'),
        'FHTLT' => described_class.new('6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT'),
        'ZLQW' => described_class.new('15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW'),
        'ZDVW' => described_class.new('13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW'),
        'WPTQ' => described_class.new('5 BMBT => 4 WPTQ'),
        'KTJDG' => described_class.new('189 ORE => 9 KTJDG'),
        'XMNCP' => described_class.new('1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP'),
        'XDBXC' => described_class.new('12 VRPVC, 27 CNZTR => 2 XDBXC'),
        'XCVML' => described_class.new('15 KTJDG, 12 BHXH => 5 XCVML'),
        'MZWV' => described_class.new('3 BHXH, 2 VRPVC => 7 MZWV'),
        'VRPVC' => described_class.new('121 ORE => 7 VRPVC'),
        'RJRHP' => described_class.new('7 XCVML => 6 RJRHP'),
        'LTCX' => described_class.new('5 BHXH, 4 VRPVC => 5 LTCX')
      }
    end
    before do
      described_class.find_levels(reactions, 'FUEL', 0)
    end

    context 'to output 1 FUEL' do
      let :output { { 'FUEL' => 1 } }

      it 'requires 2210736 ORE, nothing else' do
        expect(required['ORE']).to eq(2210736)
        expect(required.keys).to contain_exactly('ORE')
      end
    end
  end  
end
