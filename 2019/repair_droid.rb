#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 15
#
# @author oh2gxn

require 'csv'
require 'time'
require_relative 'int_code'

# Remotely operated repair droid
class RepairDroid

  # wall tiles are negative
  WALL = -1

  # input signals
  NOT_MOVED = 0
  MOVED = 1
  MOVED_AND_FOUND_OXYGEN = 2

  # directions
  DIRECTIONS = { north: { signal: 1, row: -1, col:  0 },
                 south: { signal: 2, row: 1, col: 0 },
                 west: { signal: 3, row: 0, col: -1 },
                 east: { signal: 4, row: 0, col: 1 } }.freeze

  # stopping criteria for running
  UNTIL_ALL_FOUND = 0
  UNTIL_OXYGEN_FOUND = 2

  ##
  # Set up a RepairDroid to a remote space
  # @param program [Array<Integer>] IntCode program executed by the droid
  def initialize(program)
    # content (nil = unknown, negative = wall, positive = min. distance)
    @area_size = [5, 5]
    @area = Array.new(@area_size[0]) { Array.new(@area_size[1]) }
    @row = 2
    @col = 2
    clear_distances
    @direction = DIRECTIONS.keys.first # arbitrary direction
    @promising_row = nil # bias towards some location
    @promising_col = nil # bias towards some location

    # IO to the IntCode computer
    @stop = nil # default
    @input, controller_output = IO.pipe
    controller_input, @output = IO.pipe
    @computer = IntCode.new(program, controller_input, controller_output, nil)
  end

  # Run two threads: the contoller and robot actuators
  # @param stopping_criterion [Integer] RepairDroid::UNTIL_X
  def run(stopping_criterion = UNTIL_ALL_FOUND)
    @stop = stopping_criterion
    robot = Thread.new { loop { break unless react } }
    @controller ||= Thread.new { @computer.run(0) }
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

  # clears the distance values, sets current location to 0
  def clear_distances
    @area.each_with_index do |row, r|
      row.each_with_index do |panel, c|
        next if panel.nil? # still unknown

        next if panel.negative? # keep walls

        @area[r][c] = nil # panel inside, reset
      end
    end
    @area[@row][@col] = 0
  end

  # get current Manhattan distance from starting point
  def current_distance
    @area[@row][@col]
  end

  # get maximum Manhattan distance from starting point
  def maximum_distance
    max = 0
    @area.each do |row|
      row.each do |panel|
        next if panel.nil? # still unknown

        next if panel.negative? # walls

        max = panel if panel > max
      end
    end
    max
  end

  # Read some output from IntCode controller and provide more input
  # @return [Integer, NilClass] current panel color, or nil if quit
  def react
    try_moving
    sense
  end

  private

  # finalizes movement
  # @return truthy unless quitting
  def sense
    return false if @input.eof?

    signal = @input.gets.chomp.to_i
    case signal
    when NOT_MOVED
      update_aimed_tile
    when MOVED, MOVED_AND_FOUND_OXYGEN
      move
      update_current_tile
    else
      raise(ArgumentError, "Unknown reply signal: #{signal}")
    end

    if ENV['DEBUG']
      $stderr.print "\033c" # \033c reset terminal
      $stderr.puts to_s
      sleep 0.01
    end

    case @stop
    when UNTIL_OXYGEN_FOUND
      signal != MOVED_AND_FOUND_OXYGEN
    when UNTIL_ALL_FOUND
      has_holes?
    else
      false # quit after one round
    end
  end

  # check if there can be more reachable places
  def has_holes?
    # known hole, typically close
    unless @promising_row.nil? || @promising_col.nil?
      return true if @area[@promising_row][@promising_col].nil?
    end

    # find some distant hole, save it as a side effect
    # FIXME: fails to find
    @area.each_with_index do |row, r|
      row.each_with_index do |panel, c|
        next if panel.nil? # still unknown

        next if panel.negative? # not inside

        # r,c on the seen path: check for leaks
        hole = neighbors_with_nil(r, c).first
        unless hole.nil?
          @promising_row = hole[0]
          @promising_col = hole[1]
          return true
        end
      end
    end
    false
  end

  # bias candidate directions towards known holes
  def directions_towards_promising_location
    candidates = []
    return candidates if @promising_row.nil? || @promising_col.nil?

    DIRECTIONS.each do |key, value|
      diff = [@promising_row - @row, @promising_col - @col]
      candidates << key if diff[0].positive? && value[:row].positive?
      candidates << key if diff[0].negative? && value[:row].negative?
      candidates << key if diff[1].positive? && value[:col].positive?
      candidates << key if diff[1].negative? && value[:col].negative?
    end
    candidates
  end

  # tries to move the droid
  def try_moving
    # TODO: better algorithm than biased random walk?
    neighbor = WALL # imagine hitting a wall
    direction = @direction
    until neighbor.nil? || !neighbor.negative?
      candidates = DIRECTIONS.keys # consider any direction
                     .concat([@direction]) # prefer current direction
                     .concat(directions_towards_promising_location) # prefer known hole
      # puts candidates.inspect
      direction = candidates.sample # random direction
      row = @row + DIRECTIONS[direction][:row]
      col = @col + DIRECTIONS[direction][:col]
      neighbor = @area[row][col]
    end
    @direction = direction
    @output.puts(DIRECTIONS[@direction][:signal].to_s)
  end

  # moves the current position of droid
  def move
    @row += DIRECTIONS[@direction][:row]
    prepend_height unless @row.positive?
    append_height if @row >= @area_size[0] - 1

    @col += DIRECTIONS[@direction][:col]
    prepend_width unless @col.positive?
    append_width if @col >= @area_size[1] - 1
  end

  # discover some more area at the top
  def prepend_height
    diff = 1 # @area_size[0] # doubling strategy?
    new_area = Array.new(diff) { Array.new(@area_size[1]) }
    new_area += @area
    @area = new_area
    @area_size[0] += diff
    @promising_row += diff unless @promising_row.nil?
    @row += diff
  end

  # discover some more area at the bottom
  def append_height
    diff = 1 # @area_size[0]
    @area += Array.new(diff) { Array.new(@area_size[1]) }
    @area_size[0] += diff
  end

  # discover some more area at left
  def prepend_width
    diff = 1 # @area_size[1]
    @area.each.with_index do |row, i|
      @area[i] = Array.new(diff) + row
    end
    @area_size[1] += diff
    @promising_col += diff unless @promising_col.nil?
    @col += diff
  end

  # discover some more area at right
  def append_width
    diff = 1 # @area_size[1]
    @area.each.with_index do |row, i|
      @area[i] = row + Array.new(diff)
    end
    @area_size[1] += diff
  end

  # update a wall tile
  def update_aimed_tile
    row = @row + DIRECTIONS[@direction][:row]
    col = @col + DIRECTIONS[@direction][:col]
    if @promising_row == row && @promising_row == col
      # patched a hole in the wall, find another one
      @promising_row = nil
      @promising_col = nil
    end
    @area[row][col] = WALL
  end

  # update minimum distance to current position
  def update_current_tile
    if @promising_row == @row && @promising_row == @col
      # moved onto the promising position, find new one
      hole = neighbors_with_nil(@row, @col).sample
      if hole.nil?
        # need to find a more distant one, in has_holes?
        @promising_row = nil
        @promising_col = nil
      else
        # found a nearby hole
        @promising_row = hole[0]
        @promising_col = hole[1]
      end
    end

    # update current minimum distance
    candidate = neighbors_visited(@row, @col).map { |n| @area[n[0]][n[1]] }.min + 1
    current = @area[@row][@col]
    if current.nil? || current > candidate
      # found a better route
      @area[@row][@col] = candidate
    else
      current
    end
  end

  # locations next to given one
  def neighbors(row, col)
    [[row - 1, col],
     [row + 1, col],
     [row, col - 1],
     [row, col + 1]]
  end

  # check if a location would "leak" to unknown area
  def neighbors_with_nil(row, col)
    neighbors(row, col).select { |n| @area[n[0]][n[1]].nil? }
  end

  # neighboring locations which have been seen
  def neighbors_visited(row, col)
    neighbors(row, col).reject { |n| @area[n[0]][n[1]].nil? || @area[n[0]][n[1]].negative? }
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
  t0 = Time.now.utc
  droid = RepairDroid.new(program)
  droid.run(RepairDroid::UNTIL_OXYGEN_FOUND)
  $stderr.puts droid.to_s
  t1 = Time.now.utc
  $stdout.puts "found oxygen system #{droid.current_distance} steps from starting point"
  $stdout.puts "took #{t1 - t0} s"

  # part 2
  droid.clear_distances # new starting point == oxygen system, count distances from oxygen
  droid.run(RepairDroid::UNTIL_ALL_FOUND) # continues running the same Intcode
  t2 = Time.now.utc
  $stderr.puts droid.to_s
  $stdout.puts "found everything #{droid.maximum_distance} steps from starting point"
  $stdout.puts "took #{t2 - t1} s"
end
