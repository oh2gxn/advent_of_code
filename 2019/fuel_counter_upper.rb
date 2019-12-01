#!/usr/bin/env ruby
#
# Advent of Code / 2019 / Day 1
#
# @author oh2gxn

# A module of our rocket
class RocketModule
  # Mass of the module
  attr_accessor :mass

  # Constructor
  # @param mass [Float] in kg?
  def initialize(mass)
    @mass = mass.to_f
  end

  ##
  # Computes the amount of fuel required for an individual rocket module
  # @return [Float] amount of fuel (in kg?)
  def fuel_required
    fuel = 0.0
    residual = @mass
    # could be done recursively, if you have enough stack, or tail recursion
    while residual > 0.0
      residual = fuel_to_mass(residual)
      raise "This fuel weighs more than it is worth." if residual > @mass
      fuel += residual
    end
    fuel
  end

  private

  ##
  # Fuel to mass ratio (hopefully < 1.0)
  # @param mass [Float] any mass, module or fuel
  def fuel_to_mass(mass)
    [0.0, (mass / 3.0).floor - 2.0].max
  end
end

# CLI for 1st day
mass_col = 0
fuel = 0.0
ARGF.each do |line|
  mass = Float(line.split(',')[mass_col].chomp) # TODO: CSV?
  fuel += RocketModule.new(mass).fuel_required
end
puts fuel
