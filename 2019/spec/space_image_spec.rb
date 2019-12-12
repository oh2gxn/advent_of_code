# coding: utf-8
# frozen_string_literal: true

require_relative '../space_image_format'

RSpec.describe SpaceImage do
  let :sif { described_class.new(pixels, width, height) }

  context 'with example layers' do
    let :pixels { [0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 1, 2, 0, 0, 0, 0] }
    let :width { 2 }
    let :height { 2 }

    it 'flattens as 0110' do
      expect(sif.flatten).to contain_exactly(0, 1, 1, 0)
    end

    it 'prints out as " █\n█ \n"' do
      expect(sif.to_s).to eq(" █\n█ \n")
    end
  end
end
