#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 8
#
# @author oh2gxn

# An image with layers
class SpaceImage

  # Array of image layers
  attr_accessor :layers

  # @param pixels [Array<Integer>] image content
  # @param width [Integer] number of pixels
  # @param height [Integer] number of pixels
  def initialize(pixels, width, height)
    @layers = []
    @width = width
    @height = height
    pixels.each_slice(width * height) { |l| @layers << l }
  end

  # @return [Array<Integer>]
  def layer_with_least_zeros
    index = 0
    min = @layers[0].size
    @layers.each_with_index do |l, i|
      zeros = l.count(0)
      if zeros < min
        min = zeros
        index = i
      end
    end
    @layers[index]
  end

  # crude string representation, for monospace font
  def to_s
    image = flatten
    str = StringIO.new
    image.each_slice(@width) do |row|
      line = row.map do |pixel|
        case pixel
        when 0
          ' '
        when 1
          '█'
        else
          '░'
        end
      end
      str.write(line.join + "\n")
    end
    str.string
  end

  # flatten a stack of layers, where 0 is black, 1 is white, 2 is transparent
  def flatten
    @layers.each_with_object(Array.new(@width * @height, 2)) do |layer, image|
      image.each_with_index do |pixel, i|
        image[i] = layer[i] if pixel == 2
      end
    end
  end

  # count how many pixels have particular value on a layer
  def self.count_pixels(layer, value)
    layer.count(value)
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 8th day
  width = ARGV[0].to_i
  heigth = ARGV[1].to_i
  pixels = File.open(ARGV[2]).read.chars.map(&:to_i)
  sif = SpaceImage.new(pixels, width, heigth)

  layer = sif.layer_with_least_zeros
  ones = layer.count(1)
  twos = layer.count(2)
  $stderr.puts "#{ones} * #{twos} = #{ones * twos}"

  $stdout.puts sif.to_s
end
