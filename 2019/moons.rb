#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 12
#
# @author oh2gxn

require 'csv'

# One of the celestial bodies of Jupiter
class Moon

  # 3-dim space
  DIMS = { x: 0, y: 1, z: 2 }
  
  # Array of [x,y,z] coordinates
  attr_accessor :position

  # Puts a moon on the sky at given position, with 0 velocity
  def initialize(position)
    @position = DIMS.values.map { |dim| position[dim].to_f }
    @velocity = Array.new(@position.length, 0.0)
  end

  # Applies gravity between two bodies
  def update_velocity(another_moon)
    DIMS.values.each do |dim|
      diff = another_moon.position[dim] - @position[dim]
      @velocity[dim] += if diff > 0.0
                          1.0
                        elsif diff < 0.0
                          -1.0
                        else
                          0.0
                        end
    end
  end

  # Applies current velocity to the position
  def update_position
    DIMS.values.each { |dim| @position[dim] += @velocity[dim] }
  end

  # Computes current total energy
  def total_energy
    potential_energy = 0.0
    DIMS.values.each { |dim| potential_energy += @position[dim].abs }
    kinetic_energy = 0.0
    DIMS.values.each { |dim| kinetic_energy += @velocity[dim].abs }
    potential_energy * kinetic_energy
  end

  # String representation
  def to_s
    pos = DIMS.map { |l,i| "#{l.to_s}=#{@position[i]}" }
    vel = DIMS.map { |l,i| "#{l.to_s}=#{@velocity[i]}" }
    "pos=<#{pos.join(', ')}>, vel=<#{vel.join(', ')}>"
  end

  # Execute one time step of simulation for a collection of Moons
  # @return [Float] total energy
  def self.step(moons)
    # apply gravity
    moons.each.with_index do |moon1, i|
      moons.each.with_index do |moon2, j|
        next if i == j

        moon1.update_velocity(moon2)
      end
    end

    # apply velocity
    total_energy = 0
    moons.each do |moon|
      moon.update_position
      total_energy += moon.total_energy
    end
    total_energy
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 12th day
  if ARGV.length < 2
    puts "Usage: #{$PROGRAM_NAME} initial_positions.csv INTEGER"
    return 1
  end

  initial_positions_file = ARGV[0]
  time_steps = ARGV[1].to_i

  moons = []
  CSV.foreach(initial_positions_file) do |row|
    moons << Moon.new(row)
  end
  (1..time_steps).each do |step|
    te = Moon.step(moons)
    moons.each do |moon|
      $stdout.puts step.to_s + ':' + moon.to_s
    end
    $stdout.puts step.to_s + ':' + "total:#{te}"
  end
end
