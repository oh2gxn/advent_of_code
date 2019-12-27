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
        te = 0.0
        moons.each { |moon| te += moon.total_energy }
        expect(te).to eq(0.0)
      end

      it 'has a certain total state' do
        str = described_class.hash(moons)
        expect(str).to eq('0.0,-1.0,0.0,2.0,0.0,0.0,0.0,2.0,-10.0,-7.0,0.0,0.0,0.0,4.0,-8.0,8.0,0.0,0.0,0.0,3.0,5.0,-1.0,0.0,0.0,0.0')
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

      xit 'has a certain total state' do
        str = described_class.hash(moons)
        expect(str).to eq('0.0,-1.0,0.0,2.0,0.0,0.0,0.0,2.0,-10.0,-7.0,0.0,0.0,0.0,4.0,-8.0,8.0,0.0,0.0,0.0,3.0,5.0,-1.0,0.0,0.0,0.0')
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

    context 'after 2772 steps' do
      let :time_steps { 2772 }

      it 'has the 1st moon at -1, 0, 2 with zero velocity' do
        expect(moons.first.position).to contain_exactly(-1.0, 0.0, 2.0)
        expect(moons.first.to_s).to eq('pos=<x=-1.0, y=0.0, z=2.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end

      it 'has total energy of 0' do
        te = moons.each_with_object(0.0) { |moon, sum| sum += moon.total_energy }
        expect(te).to eq(0.0)
      end

      it 'has the initial total state' do
        str = described_class.hash(moons)
        expect(str).to eq('0.0,-1.0,0.0,2.0,0.0,0.0,0.0,2.0,-10.0,-7.0,0.0,0.0,0.0,4.0,-8.0,8.0,0.0,0.0,0.0,3.0,5.0,-1.0,0.0,0.0,0.0')
      end
    end
  end

  context 'with the second example' do
    let :input do
      [[-8, -10, 0],
       [5, 5, 10],
       [2, -7, 3],
       [9, -8, -3]]
    end

    context 'before any steps' do
      let :time_steps { 0 }

      it 'has the 1st moon at -8, -10, 0 with zero velocity' do
        expect(moons.first.position).to contain_exactly(-8.0, -10.0, 0.0)
        expect(moons.first.to_s).to eq('pos=<x=-8.0, y=-10.0, z=0.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end
      it 'has the 2nd moon at 5, 5, 10 with zero velocity' do
        expect(moons[1].position).to contain_exactly(5.0, 5.0, 10.0)
        expect(moons[1].to_s).to eq('pos=<x=5.0, y=5.0, z=10.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end
      it 'has the 3rd moon at 2, -7, 3 with zero velocity' do
        expect(moons[2].position).to contain_exactly(2.0, -7.0, 3.0)
        expect(moons[2].to_s).to eq('pos=<x=2.0, y=-7.0, z=3.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end
      it 'has the 4th moon at 9, -8, -3 with zero velocity' do
        expect(moons[3].position).to contain_exactly(9.0, -8.0, -3.0)
        expect(moons[3].to_s).to eq('pos=<x=9.0, y=-8.0, z=-3.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end
    end

    context 'after 100 steps' do
      let :time_steps { 100 }

      it 'has the 1st moon at 8, -12, -9 with some velocity' do
        expect(moons.first.position).to contain_exactly(8.0, -12.0, -9.0)
        expect(moons.first.to_s).to eq('pos=<x=8.0, y=-12.0, z=-9.0>, vel=<x=-7.0, y=3.0, z=0.0>')
      end

      it 'has the 2nd moon at 13, 16, -3 with some velocity' do
        expect(moons[1].position).to contain_exactly(13.0, 16.0, -3.0)
        expect(moons[1].to_s).to eq('pos=<x=13.0, y=16.0, z=-3.0>, vel=<x=3.0, y=-11.0, z=-5.0>')
      end

      it 'has the 3rd moon at -29, -11, -1 with some velocity' do
        expect(moons[2].position).to contain_exactly(-29.0, -11.0, -1.0)
        expect(moons[2].to_s).to eq('pos=<x=-29.0, y=-11.0, z=-1.0>, vel=<x=-3.0, y=7.0, z=4.0>')
      end

      it 'has the 4th moon at 16, -13, 23 with some velocity' do
        expect(moons[3].position).to contain_exactly(16.0, -13.0, 23.0)
        expect(moons[3].to_s).to eq('pos=<x=16.0, y=-13.0, z=23.0>, vel=<x=7.0, y=1.0, z=1.0>')
      end

      it 'has total energy of 1940' do
        te = 0
        moons.each { |moon| te += moon.total_energy }
        expect(te).to eq(1940.0)
      end

      it 'has a certain total state' do
        str = described_class.hash(moons)
        expect(str).to eq('1940.0,8.0,-12.0,-9.0,-7.0,3.0,0.0,13.0,16.0,-3.0,3.0,-11.0,-5.0,-29.0,-11.0,-1.0,-3.0,7.0,4.0,16.0,-13.0,23.0,7.0,1.0,1.0')
      end
    end

    context 'after 4686774924 steps' do
      let :time_steps { 4686774924 }

      xit 'has the 1st moon at -1, 0, 2 with zero velocity' do
        expect(moons.first.position).to contain_exactly(-1.0, 0.0, 2.0)
        expect(moons.first.to_s).to eq('pos=<x=-1.0, y=0.0, z=2.0>, vel=<x=0.0, y=0.0, z=0.0>')
      end

      xit 'repeats a previous state' do
        str = described_class.hash(moons)
        expect(str).to eq('0.0,-1.0,0.0,2.0,0.0,0.0,0.0,2.0,-10.0,-7.0,0.0,0.0,0.0,4.0,-8.0,8.0,0.0,0.0,0.0,3.0,5.0,-1.0,0.0,0.0,0.0')
      end
    end
  end
end
