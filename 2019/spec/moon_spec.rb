# frozen_string_literal: true

require_relative '../moons'

RSpec.describe Moon do
  let :moons { input.map { |pos| described_class.new(pos) } }
  
  before do
    (1..time_steps).each do |step|
      described_class.step(moons)
    end
  end

  context 'with the first example' do
    let :input do
      [[-1, 0, 2],
       [2, -10, -7],
       [4, -8, 8],
       [3, 5, -1]]
    end

    context 'before any steps' do
      let :time_steps { 0 }

      it 'has the 1st moon at -1, 0, 2 with zero velocity' do
        expect(moons.first.position).to contain_exactly(-1.0, 0.0, 2.0)
        expect(moons.first.to_s).to eq('pos=<x=-1.0, y=0.0, z=2.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end

      it 'has total energy of 0' do
        te = moons.each_with_object(0.0) { |moon, sum| sum += moon.total_energy }
        expect(te).to eq(0.0)
      end
    end      

    context 'after one step' do
      let :time_steps { 1 }

      it 'has the 1st moon at 2, -1, 1' do
        expect(moons[0].position).to contain_exactly(2.0, -1.0, 1.0)
      end

      it 'has the 2nd moon at 3, -7, -4' do
        expect(moons[1].position).to contain_exactly(3.0, -7.0, -4.0)
      end

      it 'has the 3rd moon at 1, -7, 5' do
        expect(moons[2].position).to contain_exactly(1.0, -7.0, 5.0)
      end

      it 'has the 4th moon at 2, 2, 0' do
        expect(moons[3].position).to contain_exactly(2.0, 2.0, 0.0)
      end
    end      

    context 'after two steps' do
      let :time_steps { 2 }

      it 'has the 1st moon at 5, -3, -1' do
        expect(moons[0].position).to contain_exactly(5.0, -3.0, -1.0)
      end

      it 'has the 2nd moon at 1, -2, 2' do
        expect(moons[1].position).to contain_exactly(1.0, -2.0, 2.0)
      end

      it 'has the 3rd moon at 1, -4, -1' do
        expect(moons[2].position).to contain_exactly(1.0, -4.0, -1.0)
      end

      it 'has the 4th moon at 1, -4, 2' do
        expect(moons[3].position).to contain_exactly(1.0, -4.0, 2.0)
      end
    end      

    context 'after 10 steps' do
      let :time_steps { 10 }

      it 'has the 1st moon at 2,1,-3' do
        expect(moons.first.position).to contain_exactly(2, 1, -3)
      end

      it 'has total energy of 179' do
        te = 0.0
        moons.each { |moon| te += moon.total_energy }
        expect(te).to eq(179)
      end
    end
  end
end
