# frozen_string_literal: true

require_relative '../hull_painter'

RSpec.describe HullPaintingRobot do
  let :hpr { described_class.new(program) }

  # minimum smoke test
  context 'with instructions to paint the first panel white and take single step left' do
    let :program { ['3', '7', '104', '1', '104', '0', '99', '666'] }

    it 'has read the original color of start panel' do
      expect(hpr.run(7)).to eq(0)
    end

    it 'paints the start panel white' do
      hpr.run(7)
      expect(hpr.to_s).to eq(".....\n.....\n..1..\n.....\n.....\n")
    end

    it 'counts one panel painted' do
      hpr.run(7)
      expect(hpr.count_painted_panels).to eq(1)
    end
  end

  # test how the hull gets larger
  context 'with instructions for painting a white stripe of 7 panels towards top left corner' do
    let :program { ['3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1',
                    '3', '1', '104', '1', '104', '0',
                    '3', '1', '104', '0', '104', '1', '99'] }

    it 'paints the white stripe to top left corner' do
      hpr.run(1)
      expect(hpr.to_s).to eq("..........\n01........\n.01.......\n..01......\n...01.....\n....01....\n.....01...\n......01..\n..........\n..........\n")
    end
  end

  context 'with instructions for painting a diamond in 4 directions' do
    let :program { ['3', '89', '104', '1', '104', '0',
                    '3', '89', '104', '0', '104', '1',
                    '1101', '4', '-1', '13', '1005', '13', '0',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '1', '104', '0',
                    '1101', '4', '-1', '32', '1005', '32', '19',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '1', '104', '0',
                    '1101', '4', '-1', '57', '1005', '57', '44',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '1', '104', '0',
                    '1101', '4', '-1', '82', '1005', '82', '69',
                    '3', '89', '104', '0', '104', '1',
                    '3', '89', '104', '0', '104', '1',
                    '99', '73'] }

    it 'paints the diamond pattern' do
      hpr.run(89)
      expect(hpr.to_s).to eq(
        <<~PIC
        ....................
        ....................
        ....................
        ....................
        ....................
        ....................
        ....................
        ....................
        ....................
        .......00...........
        ......0110..........
        .....01..10.........
        ....01....10........
        ...01......10.......
        ...01......10.......
        ....01....10........
        .....01..10.........
        ......0110..........
        .......00...........
        ....................
        PIC
                          )
    end
  end
end
