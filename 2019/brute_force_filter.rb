#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 4
#
# @author oh2gxn

# A validator for password rules
module BruteForceFilter
  # @param password [String] a candidate
  # @return [Boolean] whether valid or not
  def self.valid?(password)
    return false unless password.match?(/^\d{6}$/)

    return false unless BruteForceFilter.non_decreasing?(password)

    return false unless BruteForceFilter.one_double_digit?(password)

    true
  end

  # @param password [String] a candidate
  # @return [Boolean] whether valid or not
  def self.non_decreasing?(password)
    max = 0
    password.each_char do |c|
      i = c.to_i
      return false if i < max

      max = [max, i].max
    end
    true
  end

  # @param password [String] a candidate
  # @return [Boolean] whether valid or not
  def self.one_double_digit?(password)
    found_doubles = []
    digit = nil
    streak = 1
    password.each_char do |c|
      i = c.to_i
      unless digit.nil?
        if digit == i
          streak += 1
        else
          # streak ends due to another digit?
          found_doubles << digit if streak == 2
          streak = 1
        end
      end
      digit = i
    end
    # streak ends due to end of string?
    found_doubles << digit if streak == 2
    !found_doubles.empty?
  end
end

if $PROGRAM_NAME == __FILE__
  # CLI for the 4th day
  ARGF.each_line do |line|
    candidate = line.chomp
    puts candidate if BruteForceFilter.valid?(candidate)
  end
end
