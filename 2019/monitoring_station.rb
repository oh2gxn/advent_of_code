#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Advent of Code / 2019 / Day 10
#
# @author oh2gxn

# Asteroid map for finding optimal places for a monitoring station
class AsteroidMap

  # Gives an empty map
  # @param colors [Hash] String -> Integer color mapping
  # Default has empty space mapped to 0, asteroids to 1
  def initialize(color_map = { '.' => 0, '#' => 1 })
    @color_map = color_map
    @width = nil
    @rows = []
  end

  # Appends one row of pixels. The first row defines map width.
  # @param pixels [Array<String>] colors on each row
  # @return [Integer] current number of rows
  def add_row(pixels)
    @width = pixels.length if @width.nil?
    @rows << pixels.map { |c| @color_map[c] } # TODO: truncate & fill to force width?
  end

  # crude string representation, for monospace font
  def to_s
    image = visible_asteroids
    str = StringIO.new
    image.each do |row|
      line = row.map do |pixel|
        if pixel.nil?
          ''
        else
          pixel.to_i
        end
      end
      str.write(line.join(',') + "\n")
    end
    str.string
  end

  # Iterate through asteroids and zap them with lazer
  # output each of the coordinates of zapped asteroids in order
  # @param column_index [Integer] coordinate of monitoring station
  # @param row_index [Integer] coordinate of monitoring station
  # @return [Array] each of the asteroid coordinates in zapping order
  def lazer_sweep(column_index, row_index)
    targets = asteroid_directions(column_index, row_index)
    coordinates = []
    until targets.empty?
      directions = targets.keys.sort
      directions.each do |direction|
        min_distance = targets[direction].min_by { |t| t[:distance] }
        targets[direction].delete(min_distance) # could just pop if sorted

        targets.delete(direction) if targets[direction].empty?

        coordinates << [column_index + min_distance[:x],
                        row_index + min_distance[:y]]
      end
    end
    coordinates
  end

  # Find the best asteroid on the map in terms of visible other asteroids
  # @return [Hash] with [Integer] :count and [Array<Integer>] :coordinates
  def best_monitoring_asteroid
    best = {}
    all = visible_asteroids
    all.each.with_index do |row, y|
      row.each.with_index do |count, x|
        next if count.nil?

        if best[:count].nil? || best[:count] < count
          best[:count] = count
          best[:coordinates] = [x, y]
        end
      end
    end
    best
  end

  # calculate visible asteroids for each non-empty pixel
  # @return [Array<Array<Integer, NilClass>>] numbers of visible asteroids, or nil where empty
  def visible_asteroids
    @rows.each_with_object([]).with_index do |(row, results), y|
      results << row.each_with_object(Array.new(@width, nil)).with_index do |(pixel, counters), x|
        next if pixel.nil? || pixel.zero?

        # count only the unique keys (one / direction)
        counters[x] = asteroid_directions(x, y).keys.length # naive quadratic search
      end
    end
  end

  # finds unique directions to each other asteroids, given column x, row y
  # @param column_index [Integer] horizontal coordinate from left
  # @param row_index [Integer] vertical coordinate from top
  # @return [Hash<String, Array>] direction => distances
  def asteroid_directions(column_index, row_index)
    directions = {}
    @rows.each.with_index do |row, y|
      row.each.with_index do |pixel, x|
        next if pixel.nil? || pixel.zero? || (x == column_index && y == row_index)

        dir, dist = compute_direction_distance(column_index, x, row_index, y)
        if directions[dir].nil?
          directions[dir] = [dist] # first one in this direction
        else
          directions[dir] << dist # list each distance, even if behind each others
        end
      end
    end
    directions
  end

  private

  # calculate some numbers: direction and squared distance
  # @param xi1 [Integer] matrix row index of monitoring station
  # @param xi2 [Integer] matrix row index of target
  # @param yi1 [Integer] matrix column index of monitoring station
  # @param yi2 [Integer] matrix column index of target
  def compute_direction_distance(xi1, xi2, yi1, yi2)
    x_diff = xi2 - xi1
    y_diff = yi2 - yi1
    sq_dist = x_diff**2 + y_diff**2

    denom = x_diff.gcd(y_diff)
    x_dir = x_diff / denom
    y_dir = y_diff / denom

    dir = direction(x_dir, y_dir) # unique for each direction
    [dir, { distance: sq_dist, x: x_diff, y: y_diff }]
  end

  # Calculates direction in radians with perverted matrix coordinates instead of Cartesian ones:
  # (x_diff, y_diff) = (0, -1) points up at 0 rad
  # (x_diff, y_diff) = (1, 0) points right at pi/2 rad
  # (x_diff, y_diff) = (0, 1) points down at pi rad
  # (x_diff, y_diff) = (-1, 0) points left at 3*pi/2 rad
  # @param x_diff [Integer] difference in row indices
  # @param y_diff [Integer] difference in column indices
  # @return [Float] angle from top to target, clockwise, in (0, 2*PI)
  def direction(x_diff, y_diff)
    Math.atan2(0, -1) - Math.atan2(x_diff, y_diff)
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 10th day
  am = AsteroidMap.new
  File.readlines(ARGV[0]).each { |line| am.add_row(line.chars) }
  # $stdout.puts am.to_s
  monitoring_station = am.best_monitoring_asteroid
  $stdout.puts monitoring_station.inspect

  point = monitoring_station[:coordinates]
  am.lazer_sweep(point[0], point[1]).each.with_index do |asteroid, index|
    $stdout.puts "#{index + 1}:#{asteroid.inspect}"
  end
end
