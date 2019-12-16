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
end
