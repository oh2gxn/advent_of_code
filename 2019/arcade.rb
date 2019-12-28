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

  # Tile IDs
  EMPTY = 0
  WALL = 1
  BLOCK = 2
  PADDLE = 3
  BALL = 4

  ##
  # Set up an arcade cabinet
  # @param program [Array<Integer>] IntCode program executed
  def initialize(program)
    # TODO: use ruby2d gem for actual graphics?
    @screen_size = [1, 1]
    @screen = Array.new(@screen_size[0]) { Array.new(@screen_size[1]) }
    @score = nil

    # IO to the IntCode computer
    @input, @controller_output = IO.pipe
    controller_input, @output = IO.pipe
    @computer = IntCode.new(program, controller_input, @controller_output, nil)

    # cheating
    @paddle_col = nil
    @ball_col = nil
    @joystick_delay = 3 # wait for the ball to come closer at the beginning, HACK
  end

  # Run two threads: the contoller and rendering
  # Join only the controller thread and return whatever it came up with.
  # @param ptr [Integer] address of the IntCode program
  # @return [Integer] final value of the IntCode memory at ptr
  def run(ptr)
    @output.puts('0') # have the game running, not blocking on input
    controller = Thread.new { @computer.run(ptr) }
    renderer = Thread.new { loop { break if render.nil? } }
    controller.join
    @controller_output.close # TODO: have this at the end of IntCode.run?
    renderer.join # wait for the last tile
    controller.value
  end

  # Print out some textual representation
  def to_s
    str = StringIO.new
    @screen.each do |row|
      line = row.map do |tile_id|
        case tile_id
        when EMPTY
          ' '
        when WALL
          '█'
        when BLOCK
          '░'
        when PADDLE
          '▓'
        when BALL
          '◯'
        else
          '.'
        end
      end
      str.write(line.join + "\n")
    end
    str.string + "#{@score}\n"
  end

  # Count how many tiles have certain content
  # @param type [Integer] e.g. BLOCK for block tiles
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

  # computer player / cheat mode
  # @return [Integer] direction of required paddle movement
  def paddle_direction
    return 0 if @paddle_col.nil? || @ball_col.nil?

    # wait for the ball to hit the paddle first
    if @paddle_col == @ball_col
      @joystick_delay = 0
      return 0
    end
    return 0 if @joystick_delay.positive?

    # time to move
    @paddle_col < @ball_col ? 1 : -1
  end

  # Read some output from IntCode controller and provide more input
  # @return [Integer, NilClass] current panel color, or nil if quit
  def render
    return nil if @input.eof?

    # graphics
    col = @input.gets.chomp.to_i
    row = @input.gets.chomp.to_i
    type = @input.gets.chomp.to_i
    res = paint(row, col, type)

    if game_started?
      # wait for the whole screen to render
      # TODO: frame sync would be useful!
      sleep 0.01
      $stdout.print "\033c" # \033c reset terminal
      $stdout.puts to_s

      # TODO: get input from keyboard instead of paddle_direction()
      @output.puts(paddle_direction.to_s) if type == BALL # cheat mode
    end

    res
  end

  private

  # guess when the game has started
  def game_started?
    !@score.nil? # count_tiles(WALL) >= 45 + 23 + 23
  end

  # paints current panel
  # @return [Integer, NilClass] painted color, or nil if quitting
  def paint(row, col, type)
    # special instructions used for printing scores
    if row.negative? || col.negative?
      @score = type
      return type
    end

    # TODO: knowing the screen size 45x24 in advance would be handy!
    append_height(row) if row >= @screen_size[0]
    append_width(col) if col >= @screen_size[1]

    case type
    when EMPTY, WALL, BLOCK
      @screen[row][col] = type
    when PADDLE
      @paddle_col = col # cheat
      @screen[row][col] = type
    when BALL
      @ball_col = col # cheat
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
    puts "Usage: #{$PROGRAM_NAME} int_code.csv [COINS]"
    return 1
  end

  program = CSV.read(ARGV[0]).first
  program[0] = 2 if ARGV.length > 1

  game = Arcade.new(program)
  game.run(0)
  $stdout.puts '----'
  $stdout.puts "The final screen has #{game.count_tiles(Arcade::BLOCK)} block tiles"
end
