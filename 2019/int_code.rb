#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 2+5+7+9
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

  # opcode of relative base offset
  RBO = 9

  # opcode of halt instruction
  HALT = 99

  # opcode => instruction mapping
  INSTRUCTIONS = {
    ADD => :add,
    MUL => :mul,
    INP => :inp,
    OUT => :out,
    JIT => :jit,
    JIF => :jif,
    CLT => :clt,
    CEQ => :ceq,
    RBO => :rbo,
    HALT => :halt
  }.freeze

  # Constructor
  # @param memory_dump [Array<Integer>] contents of RAM
  # @param input [IO] an object with gets method
  # @param output [IO] an object with puts method
  # @param err [IO, NilClass] an object with print method for interactive messages
  def initialize(memory_dump, input = STDIN, output = STDOUT, err = STDERR)
    @ram = memory_dump.map(&:to_i)
    @relative_base = 0 # pointer for relative addressing mode
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
    # @output.close # allows other threads to quit waiting for more
    @ram[pointer]
  end

  private

  ##
  # Makes sense of parameter modes & opcode
  # @param integer [Integer] an instruction
  # @return [Array] opcode and parameter modes
  def parse_instruction(integer)
    # TODO: Instruction classes? INP as "less special case", and JIT/JIF?
    opcode = integer % 100
    if [INP].include? opcode
      [opcode, (integer % 1000) / 100]
    else
      [opcode,
       (integer % 1000) / 100,
       (integer % 10_000) / 1000,
       (integer % 100_000) / 10_000]
    end
  end

  ##
  # Executes a single instruction
  # @param instruction [Array<Integer>] opcode and 3 parameter modes
  # @param pointer [Integer] current instruction pointer
  # @return [Integer] new instruction pointer
  # @raise [ArgumentError] when illegal instruction
  def execute(instruction, pointer)
    opcode, *pmodes = instruction
    raise(ArgumentError, "Illegal instruction #{opcode} at #{pointer}") unless INSTRUCTIONS.key? opcode

    send(INSTRUCTIONS[opcode], pointer, pmodes)
  end

  # execute addition at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] new instruction pointer
  def add(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @ram[args[2]] = args[0] + args[1]
    pointer + 4
  end

  # execute multiplication at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] new instruction pointer
  def mul(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @ram[args[2]] = args[0] * args[1]
    pointer + 4
  end

  # execute input at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 2=relative
  # @return [Integer] new instruction pointer
  def inp(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @err&.print PROMPT
    @ram[args[0]] = Integer(@input.gets) # NOTE: INP is a special case in terms of output
    pointer + 2
  end

  # execute output at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate, 2=relative
  # @return [Integer] new instruction pointer
  def out(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @output.puts args[0].to_s
    @output.flush
    pointer + 2
  end

  # execute jump if true at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] modified instruction pointer!
  def jit(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    return args[1] unless args[0].zero?

    pointer + 3
  end

  # execute jump if false at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] modified instruction pointer!
  def jif(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    return args[1] if args[0].zero?

    pointer + 3
  end

  # execute comparison less than at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] new instruction pointer
  def clt(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @ram[args[2]] = args[0] < args[1] ? 1 : 0
    pointer + 4
  end

  # execute comparison equals at a memory location
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] new instruction pointer
  def ceq(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @ram[args[2]] = args[0] == args[1] ? 1 : 0
    pointer + 4
  end

  # accumulate relative base
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes
  # @return [Integer] new instruction pointer
  def rbo(pointer, pmodes)
    args = get_parameters(pointer, pmodes)
    @relative_base += args[0] # TODO: guard against negative values?
    pointer + 2
  end

  # just updates pointer, not meant to do anything
  # @param pointer [Integer] instruction pointer
  # @return [Integer] pointer+1
  def halt(pointer, _pmodes)
    # another special case
    pointer + 1
  end

  # fetches proper instruction parameters according to parameter modes
  # @param pointer [Integer] instruction pointer
  # @param pmodes [Array<Integer>] parameter modes, 0=pointer, 1=immediate
  def get_parameters(pointer, pmodes)
    pmodes.map.with_index do |pmode, i|
      immediate = @ram[pointer + 1 + i].to_i # assumes @ram[*] = 0
      if i+1 < pmodes.length # input arguments
        case pmode
        when 0 # position mode
          raise(ArgumentError, "Illegal absolute address #{immediate} at #{pointer}") if immediate.negative?

          @ram[immediate].to_i
        when 1 # immediate mode
          immediate
        when 2 # relative mode
          immediate += @relative_base
          raise(ArgumentError, "Illegal relative address #{immediate} at #{pointer}") if immediate.negative?

          @ram[immediate].to_i
        else
          raise(ArgumentError, "Illegal parameter mode #{pmode} at #{pointer}")
        end
      else # output address
        case pmode
        when 0 # position mode
          immediate
        when 2 # relative mode
          immediate + @relative_base
        else
          raise(ArgumentError, "Illegal parameter mode #{pmode} at #{pointer}")
        end
      end
    end
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
