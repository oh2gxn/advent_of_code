#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 3
#
# @author oh2gxn

require 'csv'

# Crossed wires simulation
class CrossedWire
  # All coordinates, including the central port at 0,0
  attr_accessor :points

  # Constructor
  # @param path [Array<String>] with /[RLUD]\d+/ each
  def initialize(path)
    @points = [[0, 0]]
    path.each { |line| draw(line) }
  end

  # Finds crossings with another wire
  # @return [Array<Array<Integer>>]
  def crossings(another_wire)
    return [] # TODO
  end

  private

  # Draws a straight line
  # @param line [String] direction and distance as /[RLUD]\d+/
  def draw(line)
    regex = %r{(?<direction>[RLUD])(?<distance>\d+)}
    instruction = line.match(regex)
    inc = case instruction[:direction]
          when 'R'
            [1, 0]
          when 'L'
            [-1, 0]
          when 'U'
            [0, 1]
          when 'D'
            [0, -1]
          else
            $stderr.puts "Line: '#{line}'"
            [0, 0]
          end
    point = @points.last
    d_max = instruction[:distance].to_i
    (1..d_max).each do |d|
      new_point = [point[0] + d * inc[0],
                   point[1] + d * inc[1]]
      @points << new_point
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # CLI for the 3rd day
  if ARGV.length < 1
    puts "Usage: $PROGRAM_NAME file.csv"
    return 1
  end

  previous_wire = nil
  CSV.foreach(ARGV[0]) do |row|
    current_wire = CrossedWire.new(row)
    unless previous_wire.nil?
      puts "#{current_wire.points.inspect}"
    end
    previous_wire = current_wire
  end
end
