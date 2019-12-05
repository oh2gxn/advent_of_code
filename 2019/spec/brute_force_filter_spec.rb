# frozen_string_literal: true

require_relative '../brute_force_filter'

RSpec.describe BruteForceFilter do
  describe '.valid?' do
    subject { described_class.valid?(password) }

    context 'given password abc' do
      let :password { 'abc' }
      it { is_expected.to be false }
    end

    context 'given password 111111' do
      let :password { '111111' }
      it { is_expected.to be false }
    end

    context 'given password 355666' do
      let :password { '355666' }
      it { is_expected.to be true }
    end

    context 'given password 445566' do
      let :password { '445566' }
      it { is_expected.to be true }
    end

    context 'given password 456777' do
      let :password { '456777' }
      it { is_expected.to be false }
    end

    context 'given password 777777' do
      let :password { '777777' }
      it { is_expected.to be false }
    end

    context 'given password 788999' do
      let :password { '788999' }
      it { is_expected.to be true }
    end

    context 'given password 788899' do
      let :password { '788899' }
      it { is_expected.to be true }
    end

    context 'given password 888888' do
      let :password { '888888' }
      it { is_expected.to be false }
    end
  end
end
