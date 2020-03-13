# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'cube_trainer/training/input_item'
require 'cube_trainer/letter_pair'
require 'cube_trainer/letter_pair_sequence'
require 'cube_trainer/pao_letter_pair'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Training
    # The part of the result that basically comes from the input of whoever is
    # learning.
    PartialResult = Struct.new(:time_s, :failed_attempts, :word)

    # Result of giving one task to the learner and judging their performance.
    class Result
      extend Core
      include Utils::StringHelper
      # Number of columns in the UI.
      COLUMNS = 3

      INPUT_REPRESENTATION_CLASSES = [
        LetterPair,
        PaoLetterPair,
        AlgName,
        LetterPairSequence,
        Core::Algorithm
      ].freeze

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/ParameterLists
      def initialize(mode, timestamp, time_s, input_representation, failed_attempts, word)
        raise TypeError, "Invalid mode #{mode}." unless mode.is_a?(Symbol)
        raise TypeError, "Invalid timestamp #{timestamp}." unless timestamp.is_a?(Time)
        raise TypeError, "Invalid time_s #{time_s}." unless time_s.is_a?(Float)
        unless failed_attempts.is_a?(Integer)
          raise TypeError, "Invalid failed attempts #{failed_attempts}."
        end
        raise TypeError, "Invalid word #{word}." unless word.nil? || word.is_a?(String)

        check_input_representation(input_representation)
        @mode = mode
        @timestamp = timestamp
        @time_s = time_s
        @input_representation = input_representation
        @failed_attempts = failed_attempts
        @word = word
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/CyclomaticComplexity

      def check_input_representation(input_representation)
        return if INPUT_REPRESENTATION_CLASSES.any? { |c| input_representation.is_a?(c) }

        raise ArgumentError, "Invalid input representation #{input_representation}."
      end

      def self.from_partial(mode, timestamp, partial_result, input_representation)
        new(
          mode,
          timestamp,
          partial_result.time_s,
          input_representation,
          partial_result.failed_attempts,
          partial_result.word
        )
      end

      # Construct from data stored in the db.
      def self.from_raw_data(data)
        raw_mode, timestamp, time_s, raw_input, failed_attempts, word = data
        mode = raw_mode.to_sym
        Result.new(
          mode,
          Time.at(timestamp),
          time_s,
          parse_input_representation(mode, raw_input),
          failed_attempts,
          word
        )
      end

      def self.parse_input_representation(mode, raw_input)
        case mode
        when :letters_to_word
          PaoLetterPair.from_raw_data(raw_input)
        when :plls_by_name, :oh_plls_by_name
          AlgName.from_raw_data(raw_input)
        when :corner_twists_plus_parities_ul_ub
          LetterPairSequence.from_raw_data(raw_input)
        when :memo_rush
          parse_cube_algorithm(raw_input)
        else
          LetterPair.from_raw_data(raw_input)
        end
      end

      # Serialize to data stored in the db.
      def to_raw_data
        [
          @mode.to_s,
          @timestamp.to_i, # rubocop:disable Lint/NumberConversion
          @time_s,
          @input_representation.to_raw_data,
          @failed_attempts,
          @word
        ]
      end

      attr_reader :mode, :timestamp, :time_s, :input_representation, :failed_attempts, :word

      def formatted_time
        format_time(@time_s)
      end

      def with_word(new_word)
        Result.new(@timestamp, @time_s, @input_representation, @failed_attempts, new_word)
      end

      def formatted_timestamp
        @timestamp.to_s
      end

      # Columns that are displayed in the UI.
      def columns
        [formatted_timestamp, formatted_time, failed_attempts.to_s]
      end
    end
  end
end