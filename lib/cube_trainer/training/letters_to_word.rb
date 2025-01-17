# frozen_string_literal: true

require 'cube_trainer/training/input_sampler'
require 'cube_trainer/training/part_cycle_alg_set'
require 'cube_trainer/pao_letter_pair'
require 'cube_trainer/training/dict'

module CubeTrainer
  module Training
    # Class that generates input items for mapping letter pairs to words.
    # TODO: The dependency on PartCycleAlgSet is weird and doesn't make sense any more.
    class LettersToWord < PartCycleAlgSet
      def initialize(results_model, options)
        super
        @results_model = results_model
      end

      # TODO: The setup with badness makes much less sense here and should be revised.
      def goal_badness
        5.0
      end

      def letter_pairs(letterss)
        letterss.map { |ls| LetterPair.new(ls) }
      end

      def generate_letter_pairs
        alphabet = letter_scheme.alphabet
        pairs = letter_pairs(alphabet.permutation(2))
        duplicates = letter_pairs(alphabet.map { |c| [c, c] })
        singles = letter_pairs(alphabet.permutation(1))
        valid_pairs = pairs - duplicates + singles
        PaoLetterPair::PAO_TYPES.product(valid_pairs).map { |c| PaoLetterPair.new(*c) }
      end

      attr_reader :input_sampler

      # TODO: move this to the dict
      def hinter
        self
      end

      def dict
        @dict ||= Dict.new
      end

      def hints_for_new_word(pao_letter_pair)
        letter_pair = pao_letter_pair.letter_pair
        if letter_pair.letters.first.casecmp('x').zero?
          dict.words_for_regexp(letter_pair.letters[1], Regexp.new(letter_pair.letters[1]))
        else
          dict.words_for_regexp(letter_pair.letters.first, letter_pair.regexp)
        end
      end

      def hints(pao_letter_pair)
        word = @results_model.last_word_for_input(pao_letter_pair)
        if word.nil?
          hints_for_new_word(pao_letter_pair)
        else
          [word]
        end
      end

      def good_word?(input, word)
        return false unless input.matches_word?(word)

        other_combinations = @results_model.inputs_for_word(word) - [input]
        return false unless other_combinations.empty?

        last_word = @results_model.last_word_for_input(input)
        last_word.nil? || last_word == word
      end
    end
  end
end
