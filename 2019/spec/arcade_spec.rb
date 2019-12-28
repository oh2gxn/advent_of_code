# coding: utf-8
# frozen_string_literal: true

require_relative '../arcade'

RSpec.describe Arcade do
  let :game { described_class.new(program) }

  context 'with instructions to paint each of the available tiles' do
    let :program { ['104', '0', '104', '0', '104', '1',
                    '104', '0', '104', '1', '104', '1',
                    '104', '0', '104', '2', '104', '1',
                    '104', '0', '104', '3', '104', '1',
                    '104', '0', '104', '4', '104', '1',
                    '104', '1', '104', '0', '104', '1',
                    '104', '1', '104', '1', '104', '2', # block
                    '104', '1', '104', '2', '104', '0', # empty
                    '104', '1', '104', '3', '104', '4', # ball
                    '104', '1', '104', '4', '104', '3', # paddle
                    '104', '2', '104', '0', '104', '1',
                    '104', '2', '104', '1', '104', '1',
                    '104', '2', '104', '2', '104', '1',
                    '104', '2', '104', '3', '104', '1',
                    '104', '2', '104', '4', '104', '1',
                    '104', '-1', '104', '0', '104', '222', # score
                    '99', '666'] }

    it 'renders the set of tiles and the score' do
      game.run(0)
      expect(game.to_s).to eq("███\n█░█\n█ █\n█◯█\n█▓█\n222\n")
    end

    it 'counts one block tile' do
      game.run(0)
      expect(game.count_tiles(2)).to eq(1)
    end
  end
end
