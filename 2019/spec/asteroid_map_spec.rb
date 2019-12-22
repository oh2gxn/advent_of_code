# frozen_string_literal: true

require_relative '../monitoring_station'

RSpec.describe AsteroidMap do
  let :amap { described_class.new }

  context 'with the first example' do
    before do
      amap.add_row(['.', '#', '.', '.', '#'])
      amap.add_row(['.', '.', '.', '.', '.'])
      amap.add_row(['#', '#', '#', '#', '#'])
      amap.add_row(['.', '.', '.', '.', '#'])
      amap.add_row(['.', '.', '.', '#', '#'])
    end

    it 'prints out as ".7..7\n.....\n67775\n....7\n...87\n"' do
      expect(amap.to_s).to eq(",7,,,7\n,,,,\n6,7,7,7,5\n,,,,7\n,,,8,7\n")
    end
  end

  context 'with the second example' do
    before do
      amap.add_row(['.', '.', '.', '.', '.', '.', '#', '.', '#', '.'])
      amap.add_row(['#', '.', '.', '#', '.', '#', '.', '.', '.', '.'])
      amap.add_row(['.', '.', '#', '#', '#', '#', '#', '#', '#', '.'])
      amap.add_row(['.', '#', '.', '#', '.', '#', '#', '#', '.', '.'])
      amap.add_row(['.', '#', '.', '.', '#', '.', '.', '.', '.', '.'])
      amap.add_row(['.', '.', '#', '.', '.', '.', '.', '#', '.', '#'])
      amap.add_row(['#', '.', '.', '#', '.', '.', '.', '.', '#', '.'])
      amap.add_row(['.', '#', '#', '.', '#', '.', '.', '#', '#', '#'])
      amap.add_row(['#', '#', '.', '.', '.', '#', '.', '.', '#', '.'])
      amap.add_row(['.', '#', '.', '.', '.', '.', '#', '#', '#', '#'])
    end

    it 'contains one asteroid with max 33 other visible asteroids' do
      expect(amap.visible_asteroids.flatten.compact.max).to eq(33)
    end

    it 'has 33 visible asteroids at 5,8' do
      expect(amap.visible_asteroids[8][5]).to eq(33)
    end
  end

  context 'with the third example' do
    before do
      amap.add_row(['#', '.', '#', '.', '.', '.', '#', '.', '#', '.'])
      amap.add_row(['.', '#', '#', '#', '.', '.', '.', '.', '#', '.'])
      amap.add_row(['.', '#', '.', '.', '.', '.', '#', '.', '.', '.'])
      amap.add_row(['#', '#', '.', '#', '.', '#', '.', '#', '.', '#'])
      amap.add_row(['.', '.', '.', '.', '#', '.', '#', '.', '#', '.'])
      amap.add_row(['.', '#', '#', '.', '.', '#', '#', '#', '.', '#'])
      amap.add_row(['.', '.', '#', '.', '.', '.', '#', '#', '.', '.'])
      amap.add_row(['.', '.', '#', '#', '.', '.', '.', '.', '#', '#'])
      amap.add_row(['.', '.', '.', '.', '.', '.', '#', '.', '.', '.'])
      amap.add_row(['.', '#', '#', '#', '#', '.', '#', '#', '#', '.'])
    end

    it 'contains one asteroid with max 35 other visible asteroids' do
      expect(amap.visible_asteroids.flatten.compact.max).to eq(35)
    end

    it 'has 35 visible asteroids at 1,2' do
      expect(amap.visible_asteroids[2][1]).to eq(35)
    end
  end

  context 'with the fourth example' do
    before do
      amap.add_row(['.', '#', '.', '.', '#', '.', '.', '#', '#', '#'])
      amap.add_row(['#', '#', '#', '#', '.', '#', '#', '#', '.', '#'])
      amap.add_row(['.', '.', '.', '.', '#', '#', '#', '.', '#', '.'])
      amap.add_row(['.', '.', '#', '#', '#', '.', '#', '#', '.', '#'])
      amap.add_row(['#', '#', '.', '#', '#', '.', '#', '.', '#', '.'])
      amap.add_row(['.', '.', '.', '.', '#', '#', '#', '.', '.', '#'])
      amap.add_row(['.', '.', '#', '.', '#', '.', '.', '#', '.', '#'])
      amap.add_row(['#', '.', '.', '#', '.', '#', '.', '#', '#', '#'])
      amap.add_row(['.', '#', '#', '.', '.', '.', '#', '#', '.', '#'])
      amap.add_row(['.', '.', '.', '.', '.', '#', '.', '#', '.', '.'])
    end

    it 'contains one asteroid with max 41 other visible asteroids' do
      expect(amap.visible_asteroids.flatten.compact.max).to eq(41)
    end

    it 'has 41 visible asteroids at 6,3' do
      expect(amap.visible_asteroids[3][6]).to eq(41)
    end
  end

  context 'with the fifth example' do
    before do
      amap.add_row(['.', '#', '.', '.', '#', '#', '.', '#', '#', '#', '.', '.', '.', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['#', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '.', '.', '#', '#', '.'])
      amap.add_row(['.', '#', '.', '#', '#', '#', '#', '#', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '.', '#'])
      amap.add_row(['.', '#', '#', '#', '.', '#', '#', '#', '#', '#', '#', '#', '.', '#', '#', '#', '#', '.', '#', '.'])
      amap.add_row(['#', '#', '#', '#', '#', '.', '#', '#', '.', '#', '.', '#', '#', '.', '#', '#', '#', '.', '#', '#'])
      amap.add_row(['.', '.', '#', '#', '#', '#', '#', '.', '.', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['#', '.', '#', '#', '#', '#', '.', '.', '.', '.', '#', '#', '#', '.', '#', '.', '#', '.', '#', '#'])
      amap.add_row(['#', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['#', '#', '#', '#', '#', '.', '#', '#', '.', '#', '#', '#', '.', '.', '#', '#', '#', '#', '.', '.'])
      amap.add_row(['.', '.', '#', '#', '#', '#', '#', '#', '.', '.', '#', '#', '.', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['#', '#', '#', '#', '.', '#', '#', '.', '#', '#', '#', '#', '.', '.', '.', '#', '#', '.', '.', '#'])
      amap.add_row(['.', '#', '#', '#', '#', '#', '.', '.', '#', '.', '#', '#', '#', '#', '#', '#', '.', '#', '#', '#'])
      amap.add_row(['#', '#', '.', '.', '.', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '.', '.', '.'])
      amap.add_row(['#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '.', '#', '#', '#', '#', '#', '#', '#'])
      amap.add_row(['.', '#', '#', '#', '#', '.', '#', '.', '#', '#', '#', '.', '#', '#', '#', '.', '#', '.', '#', '#'])
      amap.add_row(['.', '.', '.', '.', '#', '#', '.', '#', '#', '.', '#', '#', '#', '.', '.', '#', '#', '#', '#', '#'])
      amap.add_row(['.', '#', '.', '#', '.', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '#', '.', '#', '#', '#'])
      amap.add_row(['#', '.', '#', '.', '#', '.', '#', '#', '#', '#', '#', '.', '#', '#', '#', '#', '.', '#', '#', '#'])
      amap.add_row(['#', '#', '#', '.', '#', '#', '.', '#', '#', '#', '#', '.', '#', '#', '.', '#', '.', '.', '#', '#'])
    end
    
    it 'contains one asteroid with max 210 other visible asteroids' do
      expect(amap.visible_asteroids.flatten.compact.max).to eq(210)
    end

    it 'has 210 visible asteroids at 11,13' do
      expect(amap.visible_asteroids[13][11]).to eq(210)
    end

    it 'has most visible asteroids at 11,13' do
      expect(amap.best_monitoring_asteroid[:coordinates]).to contain_exactly(11, 13)
    end

    it 'the best monitoring asteroid has 210 other visible asteroids' do
      expect(amap.best_monitoring_asteroid[:count]).to eq(210)
    end

    context 'station at 11,13' do
      let :x { 11 }
      let :y { 13 }
      subject { amap.lazer_sweep(x, y) }

      it 'will vaporize asteroid at 11,12 first' do
        expect(subject.first).to contain_exactly(11, 12)
      end

      it 'will vaporize asteroid at 12,1 second' do
        expect(subject[1]).to contain_exactly(12, 1)
      end

      it 'will vaporize asteroid at 12,2 third' do
        expect(subject[2]).to contain_exactly(12, 2)
      end

      it 'will vaporize asteroid at 12,8 tenth' do
        expect(subject[9]).to contain_exactly(12, 8)
      end

      it 'will vaporize asteroid at 16,0 20th' do
        expect(subject[19]).to contain_exactly(16, 0)
      end

      it 'will vaporize asteroid at 16,9 50th' do
        expect(subject[49]).to contain_exactly(16, 9)
      end

      it 'will vaporize asteroid at 10,16 100th' do
        expect(subject[99]).to contain_exactly(10, 16)
      end

      it 'will vaporize asteroid at 9,6 199th' do
        expect(subject[198]).to contain_exactly(9, 6)
      end

      it 'will vaporize asteroid at 8,2 200th' do
        expect(subject[199]).to contain_exactly(8, 2)
      end

      it 'will vaporize asteroid at 10,9 201st' do
        expect(subject[200]).to contain_exactly(10, 9)
      end

      it 'will vaporize asteroid at 11,1 last' do
        expect(subject.last).to contain_exactly(11, 1)
      end
    end
  end
end
