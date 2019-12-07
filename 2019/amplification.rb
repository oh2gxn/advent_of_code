#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 7
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

# Sequence of IntCode virtual machines running a program
class AmplifierCascade

  ##
  # Set up a bunch of Amplifiers
  # The last one will write to given IO.
  # @param program [Array<Integer>] IntCode program executed by each amplifier
  # @param phases [Array<String>] integers given to each amplifier as phase setting
  # @param output [IO] last amplifier will puts the final result here
  def initialize(program, phases, output = STDOUT)
    @amps = []
    return if phases.nil? || phases.empty?

    # input to the first stage
    rd, input = IO.pipe
    input.puts(phases.first) # inject phase data for the first amp
    input.puts('0') # input for the first amp

    # partially misaligned loop over following amps & IO
    phases[1..-1].each do |phase|
      rd_next, wt = IO.pipe
      wt.puts(phase) # inject phase data for next amp, as if written by this amp
      @amps << IntCode.new(program, rd, wt, nil)
      rd = rd_next
    end
    @amps << IntCode.new(program, rd, output, nil)
  end

  # Run each of the Amplifiers in the chain
  def run(ptr)
    # TODO: threads and stuff?
    res = nil
    @amps.each do |amp|
      res = amp.run(ptr)
    end
    res
  end
end

if $PROGRAM_NAME == __FILE__
  # CLI for the 7th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv [phase_A, phase_B,...]"
    return 1
  end

  program = CSV.read(ARGV[0]).first
  if ARGV.length > 1
    # run single cascade of given number of amps in given phases => single output
    phases = ARGV[1..-1]
    amps = AmplifierCascade.new(program, phases, $stdout)
    amps.run(9)
  else
    # run cascade of 5 amps in all possible phases [0..4] => 5! == 120 outputs
    (0..4).each do |p0|
      (0..4).each do |p1|
        next if p0 == p1
        (0..4).each do |p2|
          next if p0 == p2 || p1 == p2
          (0..4).each do |p3|
            next if p0 == p3 || p1 == p3 || p2 == p3
            (0..4).each do |p4|
              next if p0 == p4 || p1 == p4 || p2 == p4 || p3 == p4 # hack
              phases = [p0, p1, p2, p3, p4]
              $stdout.print phases.inspect + ':'
              amps = AmplifierCascade.new(program, phases.map(&:to_s), $stdout)
              amps.run(9)
            end
          end
        end
      end
    end
  end
end
