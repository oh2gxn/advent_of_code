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
  end

  context 'with just one orbit' do
    before do
      id = 'FOO'
      child = described_class.new(id, described_class::COM_ID)
      child.add_parent(com)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 1' do
        expect(subject).to eq(1)
      end
    end    
  end  

  context 'with two direct orbits' do
    before do
      id = 'FOO'
      child = described_class.new(id, described_class::COM_ID)
      child.add_parent(com)
      id = 'BAR'
      child = described_class.new(id, described_class::COM_ID)
      child.add_parent(com)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 2' do
        expect(subject).to eq(2)
      end
    end    
  end  

  context 'with two chained orbits' do
    before do
      id1 = 'FOO'
      child1 = described_class.new(id1, described_class::COM_ID)
      child1.add_parent(com)
      id2 = 'BAR'
      child2 = described_class.new(id2, id1)
      child2.add_parent(child1)
    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 3' do
        expect(subject).to eq(3)
      end
    end    
  end  

  context 'with the bigger example' do
    before do
      input_data = [
        [described_class::COM_ID, 'B'],
        ['B', 'C'],
        ['C', 'D'],
        ['D', 'E'],
        ['E', 'F'],
        ['B', 'G'],
        ['G', 'H'],
        ['D', 'I'],
        ['E', 'J'],
        ['J', 'K'],
        ['K', 'L']
      ].shuffle
      orbit_map = { described_class::COM_ID => com }
      iteration_count = 0
      orphan_count = 0
      input_data.each do |row|
        parent_id = row[0]
        object_id = row[1]
        object = Orbit.new(object_id, parent_id) # accumulate objects
        orbit_map[object_id] = object
        parent = orbit_map[parent_id]
        orphan_count += 1 unless object.add_parent(parent)
      end
      # NOTE: input might be shuffled (non-causal), which is not nice
      until orphan_count.zero?
        iteration_count += 1
        orphan_count = 0
        orbit_map.values.each do |o|
          orphan_count += 1 if o.orphaned? && o.add_parent(orbit_map[o.parent_id]).nil?
        end
        break if iteration_count > orbit_map.size # worst case
      end

    end

    describe 'COM.count_orbits' do
      subject { com.count_orbits[:indirect] }
      it 'is 42' do
        expect(subject).to eq(42)
      end
    end    
  end  
end
