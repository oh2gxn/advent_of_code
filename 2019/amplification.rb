#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 7
#
# @author oh2gxn

require 'csv'
require_relative 'int_code'

if $PROGRAM_NAME == __FILE__
  # CLI for the 7th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} int_code.csv"
    return 1
  end

  program = CSV.read(ARGV[0]).first

  # set up IO
  r_A, w_0 = IO.pipe
  r_B, w_A = IO.pipe
  r_C, w_B = IO.pipe
  r_D, w_C = IO.pipe
  r_E, w_D = IO.pipe

  # inject phases
  phases = ['0', '1', '2', '3', '4']
  w_0.puts(phases[0])
  w_0.puts('0') # input for A
  w_A.puts(phases[1])
  w_B.puts(phases[2])
  w_C.puts(phases[3])
  w_D.puts(phases[4])

  # set up amplifiers in a chain
  amp_A = IntCode.new(program, r_A, w_A, nil)
  amp_B = IntCode.new(program, r_B, w_B, nil)
  amp_C = IntCode.new(program, r_C, w_C, nil)
  amp_D = IntCode.new(program, r_D, w_D, nil)
  amp_E = IntCode.new(program, r_E, $stdout, nil)

  # run them all
  amp_A.run(9)
  amp_B.run(9)
  amp_C.run(9)
  amp_D.run(9)
  amp_E.run(9)
  # TODO: threads?
end
