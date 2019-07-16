#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'move'
require 'options'
require 'skewb_layer_finder'
require 'skewb_state'

include CubeTrainer

SEARCH_DEPTH = 6

options = Options.parse(ARGV)

puts 'Enter scramble with spaces between moves.'
scramble_string = gets.chomp
scramble = Algorithm.new(scramble_string.split(' ').collect { |move_string| parse_skewb_move(move_string) })

layer_finder = SkewbLayerFinder.new(options.restrict_colors)
skewb_state = SkewbState.solved
scramble.apply_to(skewb_state)
puts skewb_state.to_s

layer_solutions = layer_finder.find_solutions(skewb_state, SEARCH_DEPTH)
if layer_solutions.solved?
  puts "Optimal solution has #{layer_solutions.length} moves."
  layer_solutions.extract_algorithms.each do |color, algs|
    puts color
    puts algs
    puts
  end
else
  puts "No solution found with the given limit of #{SEARCH_DEPTH} moves."
end