#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 2+5+7
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

  # opcode of jump if true
  JIT = 5

  # opcode of jump if false
  JIF = 6

  # opcode of compare less than
  CLT = 7

  # opcode of compare equals
  CEQ = 8

  # opcode of halt instruction
  HALT = 99

  # Constructor
  # @param memory_dump [Array<Integer>] contents of RAM
  # @param input [IO] an object with gets method
  # @param output [IO] an object with puts method
  # @param err [IO, NilClass] an object with print method for interactive messages
  def initialize(memory_dump, input = STDIN, output = STDOUT, err = STDERR)
    @ram = memory_dump.map(&:to_i)
    @input = input
    @output = output
    @err = err
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
      instruction_pointer = execute(instruction, instruction_pointer)
      instruction = parse_instruction(@ram[instruction_pointer])
      Thread.pass # yield to other potential emulations here
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
  # @return [Integer] new instruction pointer
  # @raise [ArgumentError] when illegal instruction
  def execute(instruction, pointer)
    opcode, *pmodes = instruction
    # TODO: Hash<Integer,Proc> instead of case expression, or Instruction factory etc..?
    case opcode
    when ADD
      add(pointer, pmodes)
    when MUL
      mul(pointer, pmodes)
    when INP
      inp(pointer, pmodes)
    when OUT
      out(pointer, pmodes)
    when JIT
      jit(pointer, pmodes)
    when JIF
      jif(pointer, pmodes)
    when CLT
      clt(pointer, pmodes)
    when CEQ
      ceq(pointer, pmodes)
    when HALT
      pointer + 1
    else
      raise(ArgumentError, "Illegal instruction #{opcode} at #{pointer}")
    end
  end

  # execute addition at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def add(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 + arg2 # TODO: pmodes[2] == 1?
    pointer + 4
  end

  # execute multiplication at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def mul(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 * arg2 # TODO: pmodes[2] == 1?
    pointer + 4
  end

  # execute input at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def inp(pointer, _pmodes)
    arg1 = @ram[pointer + 1]
    @err.print PROMPT unless @err.nil?
    @ram[arg1] = Integer(@input.gets) # TODO: pmodes[0] == 1?
    pointer + 2
  end

  # execute output at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def out(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    @output.puts arg1.to_s
    @output.flush
    pointer + 2
  end

  # execute jump if true at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] modified instruction pointer!
  def jit(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    return arg2 unless arg1.zero?

    pointer + 3
  end

  # execute jump if false at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] modified instruction pointer!
  def jif(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    return arg2 if arg1.zero?

    pointer + 3
  end

  # execute comparison less than at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def clt(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 < arg2 ? 1 : 0
    pointer + 4
  end

  # execute comparison equals at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  # @return [Integer] new instruction pointer
  def ceq(pointer, pmodes)
    arg1 = @ram[pointer + 1]
    arg1 = @ram[arg1] if pmodes[0].zero?
    arg2 = @ram[pointer + 2]
    arg2 = @ram[arg2] if pmodes[1].zero?
    arg3 = @ram[pointer + 3]
    @ram[arg3] = arg1 == arg2 ? 1 : 0
    pointer + 4
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
  vm = IntCode.new(line, $stdin, $stdout, $stderr)
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
