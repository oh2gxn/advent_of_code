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

  # calculate visible asteroids for each non-empty pixel
  # @return [Array<Array<Integer, NilClass>>] numbers of visible asteroids, or nil where empty
  def visible_asteroids
    @rows.each_with_object([]).with_index do |(row, results), y|
      results << row.each_with_object(Array.new(@width, nil)).with_index do |(pixel, counters), x|
        next if pixel.nil? || pixel.zero?

        # count only the unique keys (one / direction)
        counters[x] = asteroid_directions(x, y).length # naive quadratic search
      end
    end
  end

  # finds unique directions to each other asteroids, given column x, row y
  # @param column_index [Integer] horizontal coordinate from left
  # @param row_index [Integer] vertical coordinate from top
  # @return [Hash<String, Array>] direction vector => distances
  def asteroid_directions(column_index, row_index)
    directions = {}
    @rows.each.with_index do |row, y|
      row.each.with_index do |pixel, x|
        next if pixel.nil? || pixel.zero? || (x == column_index && y == row_index)

        key, dist = compute_key_dist(column_index, x, row_index, y)
        if directions[key].nil?
          directions[key] = [dist] # first one in this direction
        else
          directions[key] << dist # list each distance, even if behind each others
        end
      end
    end
    directions
  end

  private

  # calculate some numbers
  def compute_key_dist(x1, x2, y1, y2)
    x_diff = x1 - x2
    y_diff = y1 - y2
    sq_dist = x_diff ** 2 + y_diff ** 2

    denom = x_diff.gcd(y_diff)
    x_dir = x_diff / denom
    y_dir = y_diff / denom

    key = "#{x_dir},#{y_dir}" # unique for each direction
    [key, sq_dist]
  end

end

if $PROGRAM_NAME == __FILE__
  # CLI for the 10th day
  am = AsteroidMap.new
  File.readlines(ARGV[0]).each { |line| am.add_row(line.chars) }
  best = {}
  all = am.visible_asteroids
  all.each.with_index do |row, y|
    row.each.with_index do |count, x|
      next if count.nil?

      if best[:count].nil? || best[:count] < count
        best[:count] = count
        best[:coordinates] = [x, y]
      end
    end
  end
  $stdout.puts am.to_s
  $stderr.puts best.inspect
end
