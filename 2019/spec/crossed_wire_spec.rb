# frozen_string_literal: true

require_relative '../crossed_wire'

# TODO: have example data as shared contexts

RSpec.describe CrossedWire do
  let :subject1 { described_class.new(path1) }
  let :subject2 { described_class.new(path2) }

  describe '#manhattan_crossings' do
    let :crossings { subject2.manhattan_crossings(subject1) }

    context 'with the graphic example' do
      let :path1 { %w[R8 U5 L5 D3] }
      let :path2 { %w[U7 R6 D4 L4] }

      it 'does not include [0,0] as a crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [3,3] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([3, 3])
      end

      it 'evaluates cost 6 for the crossing at [3,3]' do
        crossing = crossings.select do |h|
          h[:point][0] == 3 && h[:point][1] == 3
        end.first
        expect(crossing[:cost]).to eq(6)
      end

      it 'includes [6,5] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([6, 5])
      end

      it 'evaluates cost 11 for the crossing at [6,5]' do
        crossing = crossings.select do |h|
          h[:point][0] == 6 && h[:point][1] == 5
        end.first
        expect(crossing[:cost]).to eq(11)
      end
    end

    context 'with the second example' do
      let :path1 { %w[R75 D30 R83 U83 L12 D49 R71 U7 L72] }
      let :path2 { %w[U62 R66 U55 R34 D71 R55 D58 R83] }

      it 'does not include [0,0] as crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [155,4] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([155, 4])
      end    
    end

    context 'with the third example' do
      let :path1 { %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51] }
      let :path2 { %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7] }

      it 'does not include [0,0] as crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [124,11] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([124, 11])
      end
    end
  end

  # NOTE: copy-paste
  describe '#path_crossings' do
    let :crossings { subject2.path_crossings(subject1) }

    context 'with the graphic example' do
      let :path1 { %w[R8 U5 L5 D3] }
      let :path2 { %w[U7 R6 D4 L4] }

      it 'does not include [0,0] as a crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [3,3] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([3, 3])
      end

      it 'evaluates cost 40 for the crossing at [3,3]' do
        crossing = crossings.select do |h|
          h[:point][0] == 3 && h[:point][1] == 3
        end.first
        expect(crossing[:cost]).to eq(40)
      end

      it 'includes [6,5] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([6, 5])
      end

      it 'evaluates cost 30 for the crossing at [6,5]' do
        crossing = crossings.select do |h|
          h[:point][0] == 6 && h[:point][1] == 5
        end.first
        expect(crossing[:cost]).to eq(30)
      end
    end

    context 'with the second example' do
      let :path1 { %w[R75 D30 R83 U83 L12 D49 R71 U7 L72] }
      let :path2 { %w[U62 R66 U55 R34 D71 R55 D58 R83] }

      it 'does not include [0,0] as crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [155,4] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([155, 4])
      end    
    end

    context 'with the third example' do
      let :path1 { %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51] }
      let :path2 { %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7] }

      it 'does not include [0,0] as crossing' do
        expect(crossings.map {|h| h[:point]}).not_to include([0, 0])
      end

      it 'includes [124,11] as a crossing' do
        expect(crossings.map {|h| h[:point]}).to include([124, 11])
      end
    end
  end
end
