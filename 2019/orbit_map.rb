#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 6
#
# @author oh2gxn

require 'csv'

# Universal Orbit Map
class Orbit

  # Name of the universal Center of Mass
  COM_ID = 'COM'

  # Name of the object
  attr_accessor :id

  # Link to parent
  attr_accessor :parent_id

  # Links to children
  attr_accessor :children

  # Current guess for tier
  attr_accessor :tier

  # Constructor
  # @param id [String] name of the object on this orbit
  # @param parent_id [String, NilClass] center of mass, if known
  def initialize(id, parent_id)
    @id = id
    @parent_id = parent_id
    # children may yet to be initialized
    @children = {}
    @tier = id == COM_ID ? 0 : nil
  end

  # Method for updating links to children
  # NOTE: the parent has to be part of contiguous map with COM
  # @param parent [Orbit, NilClass]
  # @return [Integer, NilClass] new guess for child tier
  def add_parent(parent)
    return nil if parent.nil? || parent.orphaned?

    return @tier unless parent.children[@id].nil?

    parent.children[@id] = self
    @tier = parent.tier + 1
  end

  # @return [Boolean] true if this should have a parent
  def orphaned?
    @tier.nil?
  end

  # Counts number of direct and indirect orbits this has
  # @return [Hash] with :direct and :indirect integer counts
  def count_orbits
    @children.values.each_with_object({ direct: 1, indirect: @tier }) do |child, sum|
      oc = child.count_orbits
      sum[:direct] += oc[:direct]
      sum[:indirect] += oc[:indirect]
    end
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 6th day
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} file.csv"
    return 1
  end
  file_name = ARGV[0]
  com = Orbit.new(Orbit::COM_ID, nil)
  orbit_map = { Orbit::COM_ID => com }

  iteration_count = 0
  orphan_count = 0
  CSV.foreach(file_name, col_sep: ')') do |row|
    parent_id = row[0]
    object_id = row[1]
    o = Orbit.new(object_id, parent_id)
    orbit_map[object_id] = o # accumulate objects
    parent = orbit_map[parent_id] # possibly not seen yet
    orphan_count += 1 unless o.add_parent(parent)
  end

  # NOTE: input might be shuffled (non-causal), which is not nice
  until orphan_count.zero?
    iteration_count += 1
    orphan_count = 0
    orbit_map.values.each do |o|
      orphan_count += 1 if o.orphaned? && o.add_parent(orbit_map[o.parent_id]).nil?
    end
    break if iteration_count > orbit_map.size # worst case
  end

  puts com.count_orbits[:indirect]
end
