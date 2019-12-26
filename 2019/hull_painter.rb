#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 11
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

# Emergency Hull Painting Robot
class HullPaintingRobot

  ##
  # Set up a Hull Painting Robot
  # @param program [Array<Integer>] IntCode program executed by the robot
  def initialize(program)
    # Hull paint (nil = original black), current position and direction
    @hull_size = [5, 5]
    @hull = Array.new(@hull_size[0]) { Array.new(@hull_size[1]) }
    @row = 2
    @col = 2
    @row_diff = -1 # up
    @col_diff = 0

    # IO to the IntCode computer
    @input, @controller_output = IO.pipe
    controller_input, @output = IO.pipe
    @computer = IntCode.new(program, controller_input, @controller_output, nil)
  end

  # Run two threads: the contoller and robot actuators
  # Join only the controller thread and return whatever it came up with.
  # @param ptr [Integer] address of the IntCode program
  # @return [Integer] final value of the IntCode memory at ptr
  def run(ptr)
    read # input for the 1st sensor reading
    controller = Thread.new { @computer.run(ptr) }
    robot = Thread.new { loop { break if react.nil? } }
    controller.join
    @controller_output.close # TODO: have this at the end of IntCode.run?
    robot.join # wait for robot to paint the last panel!
    controller.value
  end

  # Print out some textual representation
  def to_s
    str = StringIO.new
    @hull.each do |row|
      line = row.map do |panel|
        if panel.nil?
          '.'
        else
          panel.to_i
        end
      end
      str.write(line.join + "\n")
    end
    str.string
  end

  # Count how many panels were painted at least once
  def count_painted_panels
    count = 0
    @hull.each do |row|
      row.each do |panel|
        next if panel.nil?

        count += 1
      end
    end
    count
  end

  # Read some output from IntCode controller and provide more input
  # @return [Integer, NilClass] current panel color, or nil if quit
  def react
    return nil if paint.nil?

    turn
    move
    read
  end

  private

  # paints current panel
  # @return [Integer, NilClass] painted color, or nil if quitting
  def paint
    return nil if @input.eof?

    signal = @input.gets.chomp.to_i
    case signal
    when 0, 1
      @hull[@row][@col] = signal
    else
      raise(ArgumentError, "Unknown paint signal: #{signal}")
    end
  end

  # turns the robot
  def turn
    signal = @input.gets.chomp.to_i
    case signal
    when 0
      turn_left
    when 1
      turn_right
    else
      raise(ArgumentError, "Unknown turning signal: #{signal}")
    end
  end

  # turns 90 deg to left
  def turn_left
    # a kind of matrix multiplication
    new_row_diff = 0 - @col_diff
    new_col_diff = @row_diff + 0
    @row_diff = new_row_diff
    @col_diff = new_col_diff
  end

  # turns 90 deg to right
  def turn_right
    new_row_diff = @col_diff + 0
    new_col_diff = 0 - @row_diff
    @row_diff = new_row_diff
    @col_diff = new_col_diff
  end

  # moves the robot
  def move
    @row += @row_diff
    prepend_height if @row.negative?
    append_height if @row >= @hull_size[0]

    @col += @col_diff
    prepend_width if @col.negative?
    append_width if @col >= @hull_size[1]
  end

  # discover some more hull at the top
  def prepend_height
    diff = @hull_size[0]
    new_hull = Array.new(diff) { Array.new(@hull_size[1]) }
    new_hull += @hull
    @hull = new_hull
    @hull_size[0] += diff
    @row += diff
  end

  # discover some more hull at the bottom
  def append_height
    diff = @hull_size[0]
    @hull += Array.new(diff) { Array.new(@hull_size[1]) }
    @hull_size[0] += diff
  end

  # discover some more hull at left
  def prepend_width
    diff = @hull_size[1]
    @hull.each.with_index do |row, i|
      @hull[i] = Array.new(diff) + row
    end
    @hull_size[1] += diff
    @col += diff
  end

  # discover some more hull at right
  def append_width
    diff = @hull_size[1]
    @hull.each.with_index do |row, i|
      @hull[i] = row + Array.new(diff)
    end
    @hull_size[1] += diff
  end

  # reads the color of current panel
  # @return [Integer] color
  def read
    color = @hull[@row][@col].to_i
    @output.puts(color.to_s)
    color
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 11th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv"
    return 1
  end

  program = CSV.read(ARGV[0]).first
  hpr = HullPaintingRobot.new(program)
  hpr.run(0)
  $stdout.puts hpr.to_s
  $stdout.puts "painted #{hpr.count_painted_panels} panels"
end
