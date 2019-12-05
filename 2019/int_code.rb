#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 2
#
# @author oh2gxn

require 'csv'

# Intcode computer emulation
class IntCode

  # Current state
  attr_accessor :ram

  # opcode of addition
  ADD = 1

  # opcode of multiplication
  MUL = 2

  # opcode of halt instruction
  HALT = 99

  # Constructor
  # @param memory_dump [Array<Integer>] contents of RAM
  def initialize(memory_dump)
    @ram = memory_dump.map(&:to_i)
  end

  ##
  # Executes the program, starting from 0
  # @param pointer [Integer] memory location of the return value
  # @return [Integer] final value at the pointer (unless eternal loop, or empty ram)
  def run(pointer)
    return nil if @ram.nil? || @ram.size.zero?

    instruction_pointer = 0
    opcode = @ram[instruction_pointer]
    while opcode != HALT
      inc = execute(opcode, instruction_pointer)
      instruction_pointer += inc
      opcode = @ram[instruction_pointer]
    end
    @ram[pointer]
  end

  private

  ##
  # Executes a single instruction
  # @param opcode [Integer] operation
  # @param pointer [Integer] current program pointer
  # @return [Integer,NilClass] increment to program pointer, nil when illegal instruction
  def execute(opcode, pointer)
    case opcode
    when ADD
      ptr1 = @ram[pointer + 1]
      ptr2 = @ram[pointer + 2]
      ptr3 = @ram[pointer + 3]
      @ram[ptr3] = @ram[ptr1] + @ram[ptr2]
      4
    when MUL
      ptr1 = @ram[pointer + 1]
      ptr2 = @ram[pointer + 2]
      ptr3 = @ram[pointer + 3]
      @ram[ptr3] = @ram[ptr1] * @ram[ptr2]
      4
    when HALT
      1
    else
      raise ArgumentError "Illegal instruction at #{instruction_pointer}"
    end
  end

end

DEFAULT_MIN = 0

# "1" -> (1..1)
# "1:5" -> (1..5)
# @param str [String] number or start:end
# @return [Range]
def parse_range(str)
  ends = str.split(':')
  if ends.empty?
    (DEFAULT_MIN..DEFAULT_MIN)
  elsif ends.length < 2
    (ends[0].to_i..ends[0].to_i)
  else
    (ends[0].to_i..ends[1].to_i)
  end
end

if $PROGRAM_NAME == __FILE__
  # CLI for the 2nd day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} file.csv [noun_min:noun_max [verb_min:verb_max]]"
    return 1
  end
  range1 = range2 = (DEFAULT_MIN..DEFAULT_MIN)
  if ARGV.length > 1
    range1 = parse_range(ARGV[1])
    range2 = parse_range(ARGV[2]) if ARGV.length > 2
  end

  range1.each do |x|
    range2.each do |y|
      CSV.foreach(ARGV[0]) do |row|
        row[1] = x
        row[2] = y
        vm = IntCode.new(row)
        res = vm.run(0)
        puts "#{x}.#{y} => #{res}"
      end
    end
  end
end
