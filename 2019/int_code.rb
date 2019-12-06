#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 2+5
#
# @author oh2gxn

require 'csv'

# Intcode computer emulation
class IntCode

  # Current state
  attr_accessor :ram

  # TEST prompt message
  PROMPT = 'TEST>'

  # opcode of addition
  ADD = 1

  # opcode of multiplication
  MUL = 2

  # opcode of input
  INP = 3

  # opcode of output
  OUT = 4

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
    instruction = parse_instruction(@ram[instruction_pointer])
    while instruction[0] != HALT
      inc = execute(instruction, instruction_pointer)
      instruction_pointer += inc
      instruction = parse_instruction(@ram[instruction_pointer])
    end
    @ram[pointer]
  end

  private

  ##
  # Makes sense of parameter modes & opcode
  # @param integer [Integer] an instruction
  # @return [Array] opcode and parameter modes
  def parse_instruction(integer)
    # TODO: Instruction class?
    [integer % 100,
     (integer % 1000) / 100,
     (integer % 10_000) / 1000,
     (integer % 100_000) / 10_000]
  end

  ##
  # Executes a single instruction
  # @param instruction [Array<Integer>] opcode and 3 parameter modes
  # @param pointer [Integer] current instruction pointer
  # @return [Integer,NilClass] increment to program pointer, nil when illegal instruction
  def execute(instruction, pointer)
    opcode, *pmodes = instruction
    case opcode
    when ADD
      add(pointer, pmodes)
      4
    when MUL
      mul(pointer, pmodes)
      4
    when INP
      inp(pointer, pmodes)
      2
    when OUT
      out(pointer, pmodes)
      2
    when HALT
      1
    else
      raise(ArgumentError, "Illegal instruction #{opcode} at #{pointer}")
    end
  end

  # execute addition at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  def add(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 + arg2 # TODO: pmodes[2] == 1?
  end

  # execute multiplication at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  def mul(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 * arg2 # TODO: pmodes[2] == 1?
  end

  # execute input at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  def inp(pointer, _pmodes)
    arg1 = @ram[pointer + 1]
    $stdout.print PROMPT
    @ram[arg1] = Integer($stdin.gets) # TODO: pmodes[0] == 1?
  end

  # execute output at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  def out(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    $stdout.puts arg1.to_s
  end

end

# "" -> nil
# "1" -> (1..1)
# "1:5" -> (1..5)
# @param str [String] number or start:end
# @return [Range, NilClass]
def parse_range(str)
  ends = str.split(':')
  if ends.empty?
    nil
  elsif ends.length < 2
    (ends[0].to_i..ends[0].to_i)
  else
    (ends[0].to_i..ends[1].to_i)
  end
end

# @param line [Array]
def run_program(line)
  noun = line[1]
  verb = line[2]
  vm = IntCode.new(line)
  res = vm.run(0)
  $stdout.puts "#{noun}.#{verb} => #{res}" # day 2 output
end

if $PROGRAM_NAME == __FILE__
  # CLI for the 2nd day and 5th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} file.csv [noun_min:noun_max [verb_min:verb_max]]"
    return 1
  end
  file_name = ARGV[0]
  range1 = range2 = nil
  if ARGV.length > 1
    # TODO: refactor this spaghetti required by day 2?
    range1 = parse_range(ARGV[1])
    if ARGV.length > 2
      range2 = parse_range(ARGV[2])
      CSV.foreach(file_name) do |row|
        range1.each do |x|
          range2.each do |y|
            row[1] = x
            row[2] = y
            run_program(row)
          end
        end
      end
    else
      CSV.foreach(file_name) do |row|
        range1.each do |x|
          row[1] = x
          run_program(row)
        end
      end
    end
  else
    CSV.foreach(file_name) { |row| run_program(row) }
  end
end
