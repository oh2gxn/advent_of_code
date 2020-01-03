#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 14
#
# @author oh2gxn

require 'csv'

# Represents one chemical reaction
class Reaction

  # Hash: String label => Integer quantity, for each input chemical
  attr_accessor :inputs

  # Hash: String label => Integer quantity, the output chemical
  attr_accessor :output

  # NilClass or Integer
  attr_accessor :level

  # Parses "34 FOO, 56 BAR => 12 ZOT" into a Reaction with
  # - 34 units of FOO and 56 units of BAR as inputs
  # - 12 units of ZOT as the output
  # @param str [String] a line of text input
  def initialize(str)
    input_str, output_str = str.split('=>').map(&:strip)
    raise(ArgumentError, "Missing input side: #{str}") if input_str.nil? || input_str.empty?
    raise(ArgumentError, "Missing output side: #{str}") if output_str.nil? || output_str.empty?

    @inputs = parse_inputs(input_str)
    @output = parse_pair(output_str)
    @level = nil # 0 when producing original desired output
  end

  # Run one iteration of search, where
  # @param required_outputs [Hash] label => quantity pairs of required amounts
  # @param available_reactions [Hash] label => Reaction pairs available
  # @return [Hash] new set of required outputs, with more raw ingredients
  def self.iterate_inputs(required_outputs, available_reactions)
    new_inputs = {}
    max_level = nil
    candidates = Reaction.sort_by_level(available_reactions, required_outputs.keys)
    candidates.each do |candidate|
      unless available_reactions.key?(candidate)
        # this is probably ORE, or something else which cannot be created
        Reaction.add_pair!(new_inputs, candidate, required_outputs[candidate])
        next # try something else
      end

      # candidate that really needs to be eliminated next?
      reaction = available_reactions[candidate]
      max_level ||= reaction.level
      if max_level < reaction.level
        # wait for further iterations
        Reaction.add_pair!(new_inputs, candidate, required_outputs[candidate])
        next
      end

      # get more of this candidate
      required_qty = required_outputs[candidate]
      multiplier = (required_qty / reaction.output[candidate].to_f).ceil
      reaction.inputs.each do |input, qty|
        Reaction.add_pair!(new_inputs, input, multiplier * qty)
      end
    end
    new_inputs
  end

  # @return [Hash] ultimate set of inputs
  def self.solve(required, reactions)
    diff = required.keys
    until diff.length.zero?
      # $stderr.puts required.inspect # DEBUG
      required = Reaction.iterate_inputs(required, reactions)
      diff = required.keys - diff
    end
    required
  end

  # Figures out some priorities
  def self.find_levels(reactions, output_label, output_level)
    current = reactions[output_label]
    return if current.nil?

    current.level = [current.level.to_i, output_level].max
    current.inputs.keys.each do |input_label|
      Reaction.find_levels(reactions, input_label, output_level + 1)
    end
  end

  # Sort an array by priority
  # @param reactions [Hash] available reactions
  # @param labels [Array] unsorted chemicals
  # @return [Array] sorted by priority
  def self.sort_by_level(reactions, labels)
    labels.sort do |cand1, cand2|
      if reactions.key?(cand1)
        if reactions.key?(cand2)
          reactions[cand1].level <=> reactions[cand2].level
        else
          -1 # cand2 == ORE
        end
      elsif reactions.key?(cand2)
        1 # cand1 == ORE
      else
        0 # both ORE?
      end
    end
  end

  # Adds required amounts: { "FOO" => 5, "BAR" => 1 } + "FOO",3 = { "FOO" => 8, "BAR" => 1}
  def self.add_pair!(hash, label, quantity)
    if hash.key? label
      hash[label] += quantity
    else
      hash[label] = quantity
    end
  end

  private

  # Parses "34 FOO" into { "FOO" => 34 }
  # @return [Hash]
  def parse_pair(str)
    qty_str, label_str = str.split(' ')
    raise(ArgumentError, "Missing quantity: #{str}") if qty_str.nil? || qty_str.empty?
    raise(ArgumentError, "Missing label: #{str}") if label_str.nil? || label_str.empty?

    { label_str => qty_str.to_i }
  end

  # Parses "34 FOO, 56 BAR, 12 ZOT" into { "FOO" => 34, "BAR" => 56, "ZOT" => 12 }
  # @return [Hash]
  def parse_inputs(str)
    str.split(', ').each_with_object({}) { |pair, all| all.merge!(parse_pair(pair)) }
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 14th day
  reactions = {}
  ARGF.each_line do |line|
    r = Reaction.new(line)
    key = r.output.keys.first
    reactions[key] = r
  end
  # TODO: sort reactions by causality?
  Reaction.find_levels(reactions, 'FUEL', 0)

  required = { 'FUEL' => 1 }
  puts Reaction.solve(required, reactions).inspect
end
