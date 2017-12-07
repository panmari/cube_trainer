#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'options'
require 'results_model'
require 'ui_helpers'
require 'console_helpers'

include UiHelpers
include ConsoleHelpers

# TODO Do this in the UI.

options = Options.parse(ARGV)
results_model = ResultsModel.new(options.commutator_info.result_symbol)
generator = options.commutator_info.generator_class.new(results_model)

found = results_model.results.length
missing = generator.class::VALID_PAIRS.length - found
if missing > 0
  puts "#{found} words found, #{missing} missing."
end

loop do
  letter_pair = generator.random_letter_pair
  puts_and_say(letter_pair)
  start = Time.now
  wait_for_any_key
  time_s = Time.now - start
  puts "Time: #{format_time(time_s)}"
  result = Result.new(start, time_s, letter_pair, 0, nil)
  results_model.record_result(result)
end