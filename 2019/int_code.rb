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

  # halt instruction
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

    pp = 0
    opcode = @ram[pp]
    while opcode != HALT
      inc = execute(opcode, pp)
      raise "Illegal instruction at #{pp}" if inc.nil?
      pp += inc
      opcode = @ram[pp]
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
    when 1
      ptr1 = @ram[pointer+1]
      ptr2 = @ram[pointer+2]
      ptr3 = @ram[pointer+3]
      @ram[ptr3] = @ram[ptr1] + @ram[ptr2]
      return 4
    when 2
      ptr1 = @ram[pointer+1]
      ptr2 = @ram[pointer+2]
      ptr3 = @ram[pointer+3]
      @ram[ptr3] = @ram[ptr1] * @ram[ptr2]
      return 4
    when HALT
      return 0
    else
      return nil
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # CLI for the 2nd day
  if ARGV.length < 1
    puts "Usage: $PROGRAM_NAME file.csv"
    return 1
  end
  CSV.foreach(ARGV[0]) do |row|
    vm = IntCode.new(row)
    puts vm.run(0)
  end
end
