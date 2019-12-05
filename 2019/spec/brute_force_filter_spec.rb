# frozen_string_literal: true

require_relative '../brute_force_filter'

RSpec.describe BruteForceFilter do
  describe '.valid?' do
    subject { described_class.valid?(password) }

    context 'given password 111111' do
      let :password { '111111' }
      it { is_expected.to be false }
    end

    context 'given password 355555' do
      let :password { '355555' }
      it { is_expected.to be true }
    end

    context 'given password 444444' do
      let :password { '444444' }
      it { is_expected.to be true }
    end

    context 'given password 777777' do
      let :password { '777777' }
      it { is_expected.to be true }
    end

    context 'given password 888888' do
      let :password { '888888' }
      it { is_expected.to be false }
    end
  end
end
