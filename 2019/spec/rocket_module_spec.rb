# frozen_string_literal: true

require_relative '../fuel_counter_upper'

RSpec.describe RocketModule do
  let :subject { described_class.new(mass) }

  context 'with mass of 14' do
    let :mass { 14 }
    it 'requires 2 units of fuel' do
      expect(subject.fuel_required).to eq(2)
    end
  end

  context 'with mass of 1969' do
    let :mass { 1969 }
    it 'requires 966 units of fuel' do
      expect(subject.fuel_required).to eq(966)
    end
  end

  context 'with mass of 100756' do
    let :mass { 100756 }
    it 'requires 50346 units of fuel' do
      expect(subject.fuel_required).to eq(50346)
    end
  end  
end
