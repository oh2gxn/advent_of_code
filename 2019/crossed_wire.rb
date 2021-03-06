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

  # The connector point
  ORIGIN = [0, 0].freeze

  # Constructor
  # @param path [Array<String>] with /[RLUD]\d+/ each
  def initialize(path)
    @points = [ORIGIN]
    path.each { |line| draw(line) }
  end

  # Finds crossings with another wire, closest Manhattan distance to 0,0 first
  # @return [Array<Hash>] cost, point tuples in the order found
  def manhattan_crossings(another_wire)
    # TODO: bounding box?
    my_points = sort_path_by_manhattan(@points)
    other_points = sort_path_by_manhattan(another_wire.points)
    cs = []
    my_points.each do |mp|
      other_points.each do |op|
        next unless mp[0] == op[0]

        next unless mp[1] == op[1]

        next if CrossedWire.l1_norm(ORIGIN, mp).zero? &&
                CrossedWire.l1_norm(ORIGIN, op).zero?

        cs << { cost: CrossedWire.l1_norm(ORIGIN, op), point: op }
        break # NOTE: self could cross op more than once, but skip it
      end
      # TODO: some other representation could skip entire segments
      # TODO: break if cs.length >= opts[:limit] ?
    end
    cs # sort by cost not required due to Manhattan properties
  end

  # Finds crossings with another wire, closest path via wire to origin first
  # @return [Array<Array<Integer>>]
  def path_crossings(another_wire)
    # TODO: bounding box?
    my_points = @points
    other_points = another_wire.points
    cs = []
    wire1_cost = 0 # NOTE: assumes 1st point == origin
    my_points.each do |mp|
      wire2_cost = 0
      other_points.each do |op|
        next if CrossedWire.l1_norm(ORIGIN, mp).zero? &&
                CrossedWire.l1_norm(ORIGIN, op).zero?

        if mp[0] == op[0] && mp[1] == op[1]
          cs << { cost: (wire1_cost + wire2_cost), point: op }
          break # NOTE: self could cross op more than once, but skip it
        end

        wire2_cost += 1 # Cost for the next point
      end
      wire1_cost += 1
      # TODO: some other representation could skip entire segments
      # TODO: break if cs.length >= 1
    end
    cs.sort_by { |h| h[:cost] }
  end

  # Computes Manhattan distance between two points
  def self.l1_norm(point1, point2)
    (point1[0] - point2[0]).abs + (point1[1] - point2[1]).abs
  end

  private

  # Draws a straight line
  # @param line [String] direction and distance as /[RLUD]\d+/
  def draw(line)
    regex = /(?<direction>[RLUD])(?<distance>\d+)/
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
            raise(ArgumentError, "Unrecognized direction of line: '#{line}'")
          end
    point = @points.last
    d_max = instruction[:distance].to_i
    (1..d_max).each do |d|
      new_point = [point[0] + d * inc[0],
                   point[1] + d * inc[1]]
      @points << new_point
    end
  end

  # @param points [Array] points
  # @return [Array<Array<Integer>>] points sorted by distance from origin
  def sort_path_by_manhattan(points)
    # NOTE: sort is not stable
    points.sort { |a, b| CrossedWire.l1_norm(ORIGIN, a) <=> CrossedWire.l1_norm(ORIGIN, b) }
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 3rd day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} file.csv"
    return 1
  end

  previous_wire = nil
  CSV.foreach(ARGV[0]) do |row|
    current_wire = CrossedWire.new(row)
    unless previous_wire.nil?
      puts "L1:#{current_wire.manhattan_crossings(previous_wire).inspect}"
      puts "L8:#{current_wire.path_crossings(previous_wire).inspect}"
    end
    previous_wire = current_wire
  end
end
