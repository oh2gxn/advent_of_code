#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 7
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

# A hack for forking output, not sure if thread safe anything
class ForkedIO

  # Have output written (puts) to original output and an input too
  # @param original_output [IO] something with #puts and #flush
  # @param another_output [IO] something with #puts
  def initialize(original_output, another_output)
    @output1 = original_output
    @output2 = another_output
  end

  # Write to both outputs
  def puts(str)
    @output2.puts(str)
    @output1.puts(str)
  end

  # Flush both outputs
  def flush
    @output2.flush
    @output1.flush
  end

end

# Sequence of IntCode virtual machines running a program
class AmplifierCascade

  ##
  # Set up a bunch of Amplifiers
  # The last one will write to given IO.
  # @param program [Array<Integer>] IntCode program executed by each amplifier
  # @param phases [Array<String>] integers given to each amplifier as phase setting
  # @param output [IO] last amplifier will puts the final result here
  # @param feedback [Boolean] true if last amp feeds back to the first one
  def initialize(program, phases, output = STDOUT, feedback = false)
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
    output = ForkedIO.new(output, input) if feedback # anon class?
    @amps << IntCode.new(program, rd, output, nil)
  end

  # Run each of the Amplifiers in the chain
  def run(ptr)
    threads = [] # threads and stuff, or else they block via IO
    @amps.each do |amp|
      threads << Thread.new { amp.run(ptr) }
    end
    threads.each { |th| th.join }
    threads.last&.value
  end
end

if $PROGRAM_NAME == __FILE__
  # CLI for the 7th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv [false/true] [phase_A, phase_B,...]"
    return 1
  end

  program = CSV.read(ARGV[0]).first
  feedback = false # default: no feedback from final Amp to first Amp
  feedback = ARGV[1] =~ /[yY1tT]/ if ARGV.length > 1
  if ARGV.length > 2
    # run single cascade of given number of amps in given phases => single output
    phases = ARGV[2..-1]
    amps = AmplifierCascade.new(program, phases, $stdout, feedback)
    amps.run(9)
  else
    # run cascade of 5 amps in all possible phases [0..4] => 5! == 120 outputs
    range = feedback ? (5..9) : (0..4)
    range.each do |p0|
      range.each do |p1|
        next if p0 == p1
        range.each do |p2|
          next if p0 == p2 || p1 == p2
          range.each do |p3|
            next if p0 == p3 || p1 == p3 || p2 == p3
            range.each do |p4|
              next if p0 == p4 || p1 == p4 || p2 == p4 || p3 == p4 # hack
              phases = [p0, p1, p2, p3, p4]
              $stdout.print phases.inspect + ':'
              amps = AmplifierCascade.new(program, phases.map(&:to_s), $stdout, feedback)
              amps.run(9)
              # TODO: replace newlines with ', ' ?
            end
          end
        end
      end
    end
  end
end
