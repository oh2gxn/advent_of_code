#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 15
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

# Remotely operated repair droid
class RepairDroid

  # wall tiles are negative
  WALL = -1

  # directions
  NORTH = 1
  SOUTH = 2
  WEST = 3
  EAST = 4

  ##
  # Set up a RepairDroid to a remote space
  # @param program [Array<Integer>] IntCode program executed by the droid
  def initialize(program)
    # content (nil = unknown, negative = wall, positive = min. distance)
    @area_size = [5, 5]
    @area = Array.new(@area_size[0]) { Array.new(@area_size[1]) }
    @row = 2
    @col = 2
    @area[@row][@col] = 0 # the 1st distance
    @row_diff = 0
    @col_diff = 1 # 1st direction = right

    # IO to the IntCode computer
    @input, controller_output = IO.pipe
    controller_input, @output = IO.pipe
    @computer = IntCode.new(program, controller_input, controller_output, nil)
  end

  # Run two threads: the contoller and robot actuators
  def run
    robot = Thread.new { loop { break if react.nil? } }
    controller = Thread.new { @computer.run(0) }
    robot.join # wait for robot to count final value
  end

  # Print out some textual representation
  def to_s
    str = StringIO.new
    @area.each_with_index do |row, r|
      line = row.map.with_index do |panel, c|
        if panel.nil?
          ' '
        elsif panel.negative?
          '█'
        elsif panel.zero?
          'X' # start position
        elsif r == @row && c == @col
          'D' # final position
        else
          '░'
        end
      end
      str.write(line.join + "\n")
    end
    str.string
  end

  # get current minimum Manhattan distance from starting point
  def current_minimum_distance
    @area[@row][@col]
  end

  # Read some output from IntCode controller and provide more input
  # @return [Integer, NilClass] current panel color, or nil if quit
  def react
    try_moving
    sense
  end

  private

  # finalizes movement
  # @return [Integer, NilClass] painted color, or nil if quitting
  def sense
    return nil if @input.eof?

    signal = @input.gets.chomp.to_i
    new_tile = case signal
               when 0
                 update_aimed_tile
               when 1, 2
                 move
                 update_current_tile
               else
                 raise(ArgumentError, "Unknown reply signal: #{signal}")
               end
    signal == 2 ? nil : new_tile
  end

  # turns the robot
  def try_moving
    # TODO: better algorithm
    neighbor = WALL
    until neighbor.nil? || !neighbor.negative?
      signal = [NORTH, SOUTH, WEST, EAST].sample # random direction
      case signal
      when NORTH
        north
      when SOUTH
        south
      when WEST
        west
      when EAST
        east
      else
        raise(ArgumentError, "Unknown movement signal: #{signal}")
      end
      neighbor = @area[@row + @row_diff][@col + @col_diff]
    end

    @output.puts(signal.to_s)
  end

  # turns north
  def north
    @row_diff = -1
    @col_diff = 0
  end

  # turns south
  def south
    @row_diff = 1
    @col_diff = 0
  end

  # turns west
  def west
    @row_diff = 0
    @col_diff = -1
  end

  # turns east
  def east
    @row_diff = 0
    @col_diff = 1
  end

  # moves the current position of droid
  def move
    @row += @row_diff
    prepend_height unless @row.positive?
    append_height if @row >= @area_size[0] - 1

    @col += @col_diff
    prepend_width unless @col.positive?
    append_width if @col >= @area_size[1] - 1
  end

  # discover some more area at the top
  def prepend_height
    diff = @area_size[0]
    new_area = Array.new(diff) { Array.new(@area_size[1]) }
    new_area += @area
    @area = new_area
    @area_size[0] += diff
    @row += diff
  end

  # discover some more area at the bottom
  def append_height
    diff = @area_size[0]
    @area += Array.new(diff) { Array.new(@area_size[1]) }
    @area_size[0] += diff
  end

  # discover some more area at left
  def prepend_width
    diff = @area_size[1]
    @area.each.with_index do |row, i|
      @area[i] = Array.new(diff) + row
    end
    @area_size[1] += diff
    @col += diff
  end

  # discover some more area at right
  def append_width
    diff = @area_size[1]
    @area.each.with_index do |row, i|
      @area[i] = row + Array.new(diff)
    end
    @area_size[1] += diff
  end

  # update a wall tile
  def update_aimed_tile
    @area[@row + @row_diff][@col + @col_diff] = WALL
  end

  # update minimum distance to current position
  def update_current_tile
    neighbors = [@area[@row - 1][@col],
                 @area[@row + 1][@col],
                 @area[@row][@col - 1],
                 @area[@row][@col + 1]]
    candidate = neighbors.reject { |d| d.nil? || d.negative? }.min + 1
    current = @area[@row][@col]
    if current.nil? || current > candidate
      @area[@row][@col] = candidate
    else
      current
    end
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 15th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv"
    return 1
  end

  program = CSV.read(ARGV[0]).first

  # part 1
  droid = RepairDroid.new(program)
  droid.run
  $stdout.puts droid.to_s
  $stdout.puts "found oxygen system #{droid.current_minimum_distance} steps from starting point"
end
