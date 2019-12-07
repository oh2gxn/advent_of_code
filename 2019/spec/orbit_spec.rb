# frozen_string_literal: true

require_relative '../orbit_map'

RSpec.describe Orbit do
  let :com { described_class.new(described_class::COM_ID, nil) }

  context 'with empty map' do
    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 0' do
        expect(subject).to be_zero
      end
    end

    describe 'COM.list_orbits' do
      subject { com.list_orbits }
      it 'is empty' do
        expect(subject).to be_an(Array)
        expect(subject).to be_empty
      end
    end
  end

  context 'with just one orbit' do
    let :child { described_class.new('FOO', described_class::COM_ID) }
    before do
      child.add_parent(com)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 1' do
        expect(subject).to eq(1)
      end
    end

    describe 'child.list_orbits' do
      subject { child.list_orbits }
      it 'it has one direct orbit, around COM' do
        expect(subject.length).to eq(1)
        expect(subject.first).to eq(com)
      end
    end
  end

  context 'with two direct orbits' do
    let :child1 { described_class.new('FOO', described_class::COM_ID) }
    let :child2 { described_class.new('BAR', described_class::COM_ID) }
    before do
      child1.add_parent(com)
      child2.add_parent(com)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 2' do
        expect(subject).to eq(2)
      end
    end
  end

  context 'with two chained orbits' do
    let :child1 { described_class.new('FOO', described_class::COM_ID) }
    let :child2 { described_class.new('BAR', described_class::COM_ID) }
    before do
      child1.add_parent(com)
      child2.add_parent(child1)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 3' do
        expect(subject).to eq(3)
      end
    end

    describe 'child2.list_orbits' do
      subject { child2.list_orbits }
      it 'it has two orbits, around COM and child1' do
        expect(subject.length).to eq(2)
        expect(subject.first).to eq(com)
        expect(subject.last).to eq(child1)
      end
    end
  end

  context 'with the bigger example' do
    let :input_data do
      [[described_class::COM_ID, 'B'],
       ['B', 'C'],
       ['C', 'D'],
       ['D', 'E'],
       ['E', 'F'],
       ['B', 'G'],
       ['G', 'H'],
       ['D', 'I'],
       ['E', 'J'],
       ['J', 'K'],
       ['K', 'L']].shuffle
    end
    let :orbit_map { { com.id => com } }
    before do
      orphan_count = 0
      input_data.each do |row|
        orphan_count += described_class.insert_new_orbit(orbit_map, row[0], row[1])
      end
      iteration_count = 0
      until orphan_count.zero?
        iteration_count += 1
        orphan_count = described_class.find_new_parents(orbit_map)
        break if iteration_count > orbit_map.size # worst case
      end
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 42' do
        expect(subject).to eq(42)
      end
    end

    describe 'D.list_orbits' do
      subject { orbit_map['D'].list_orbits }
      it 'it has three orbits, around COM, B, and C' do
        expect(subject.length).to eq(3)
        expect(subject.map(&:id)).to contain_exactly('COM', 'B', 'C')
      end
    end

    describe 'L.list_orbits' do
      subject { orbit_map['L'].list_orbits }
      it 'it has 7 orbits, around COM, B, and C' do
        expect(subject.length).to eq(7)
        expect(subject.map(&:id)).to contain_exactly('COM', 'B', 'C', 'D', 'E', 'J', 'K')
      end
    end
  end
end
