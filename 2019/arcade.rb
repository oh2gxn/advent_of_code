#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 13
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

# Game Arcade Cabinet
class Arcade

  ##
  # Set up an arcade cabinet
  # @param program [Array<Integer>] IntCode program executed
  # @todo knowing the screen size in advance would be handy!
  def initialize(program)
    # TODO: use ruby2d gem for actual graphics?
    @screen_size = [1, 1]
    @screen = Array.new(@screen_size[0]) { Array.new(@screen_size[1]) }

    # IO to the IntCode computer
    @input, @controller_output = IO.pipe
    controller_input, @output = IO.pipe
    @computer = IntCode.new(program, controller_input, @controller_output, nil)
  end

  # Run two threads: the contoller and rendering
  # Join only the controller thread and return whatever it came up with.
  # @param ptr [Integer] address of the IntCode program
  # @return [Integer] final value of the IntCode memory at ptr
  def run(ptr)
    controller = Thread.new { @computer.run(ptr) }
    renderer = Thread.new { loop { break if render.nil? } }
    controller.join
    @controller_output.close # TODO: have this at the end of IntCode.run?
    renderer.join # wait for the last pixel
    controller.value
  end

  # Print out some textual representation
  def to_s
    str = StringIO.new
    @screen.each do |row|
      line = row.map do |tile_id|
        case tile_id
        when 0
          ' '
        when 1
          '█'
        when 2
          '░'
        when 3
          '▓'
        when 4
          '◯'
        else
          '.'
        end
      end
      str.write(line.join + "\n")
    end
    str.string
  end

  # Count how many tiles have certain content
  # @param type [Integer] e.g. 2 for block tiles
  def count_tiles(type)
    count = 0
    @screen.each do |row|
      row.each do |tile_id|
        next if tile_id.nil?

        count += 1 if tile_id == type
      end
    end
    count
  end

  # Read some output from IntCode controller and provide more input
  # @return [Integer, NilClass] current panel color, or nil if quit
  def render
    return nil if @input.eof?

    row = @input.gets.chomp.to_i
    col = @input.gets.chomp.to_i
    type = @input.gets.chomp.to_i
    paint(row, col, type)

    # TODO: @output.puts('0')
  end

  private

  # paints current panel
  # @return [Integer, NilClass] painted color, or nil if quitting
  def paint(row, col, type)
    # get a bigger screen?
    append_height(row) if row >= @screen_size[0]
    append_width(col) if col >= @screen_size[1]

    case type
    when 0, 1, 2, 3, 4
      @screen[row][col] = type
    else
      raise(ArgumentError, "Unknown tile type: #{type}")
    end
  end

  # discover some more screen at the bottom
  # @param required_row [Integer] row index which should fit
  def append_height(required_row)
    diff = required_row - @screen_size[0] + 1
    @screen += Array.new(diff) { Array.new(@screen_size[1]) }
    @screen_size[0] += diff
  end

  # discover some more screen at right
  # @param required_col [Integer] column index which should fit
  def append_width(required_col)
    diff = required_col - @screen_size[1] + 1
    @screen.each.with_index do |row, i|
      @screen[i] = row + Array.new(diff)
    end
    @screen_size[1] += diff
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 13th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv"
    return 1
  end

  program = CSV.read(ARGV[0]).first

  # part 1
  game = Arcade.new(program)
  game.run(0)
  $stdout.puts game.to_s
  $stdout.puts "The final screen has #{game.count_tiles(2)} block tiles"
end
