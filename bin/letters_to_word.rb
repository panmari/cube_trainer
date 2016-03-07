#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'letters_to_word'
require 'results_model'
require 'ui_helpers'

include UiHelpers

# TODO Do this in the UI.

results_model = ResultsModel.new(:letters_to_word)
generator = LettersToWord.new(results_model)

loop do
  letter_pair = generator.random_letter_pair
  puts letter_pair
  start = Time.now
  word = ''
  failed_attempts = -1
  until letter_pair.matches_word?(word)
    word = gets.chomp
    failed_attempts += 1
  end
  time_s = Time.now - start
  puts format_time(time_s)
  result = Result.new(start, failed_attempts, letter_pair, failed_attempts, word)
  results_model.record_result(result)
end
