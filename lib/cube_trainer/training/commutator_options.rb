# frozen_string_literal: true

require 'ostruct'
require 'cube_trainer/color_scheme'
require 'cube_trainer/cube_trainer_options_parser'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/cube_scrambles'
require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'
require 'cube_trainer/training/letters_to_word'
require 'cube_trainer/training/memo_rusher'
require 'cube_trainer/training/alg_sets'

module CubeTrainer
  module Training
    # Command line options for `commutators` binary.
    class CommutatorOptions
      CommutatorInfo =
        Struct.new(
          :result_symbol,
          :generator_class,
          :learner_class,
          :default_cube_size,
          :has_buffer?
        )
      COMMUTATOR_TYPES = {
        memo_rush:
          CommutatorInfo.new(:memo_rush, CubeScrambles, MemoRusher, 3, false),
        corners:
          CommutatorInfo.new(:corner_commutators, CornerCommutators, HumanTimeLearner, 3, true),
        corner_parities:
          CommutatorInfo.new(:corner_parities_ul_ub, CornerParities, HumanTimeLearner, 3, true),
        corner_twists_plus_parities: CommutatorInfo.new(
          :corner_twists_plus_parities_ul_ub, CornerTwistsPlusParities,
          HumanTimeLearner, 3, true
        ),
        floating_2twists:
          CommutatorInfo.new(:floating_2twists, FloatingCorner2Twists, HumanTimeLearner, 3, false),
        corner_3twists:
          CommutatorInfo.new(:corner_3twists, Corner3Twists, HumanTimeLearner, 3, false),
        floating_2twists_and_corner_3twists: CommutatorInfo.new(
          :floating_2twists_and_corner_3twists, FloatingCorner2TwistsAnd3Twists,
          HumanTimeLearner, 3, false
        ),
        floating_2flips:
          CommutatorInfo.new(:floating_2flips, FloatingEdgeFlips, HumanTimeLearner, 3, false),
        edges: CommutatorInfo.new(:edge_commutators, EdgeCommutators, HumanTimeLearner, 3, true),
        wings: CommutatorInfo.new(:wing_commutators, WingCommutators, HumanTimeLearner, 4, true),
        xcenters:
          CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, HumanTimeLearner, 4, true),
        tcenters:
          CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, HumanTimeLearner, 5, true),
        words: CommutatorInfo.new(:letters_to_word, LettersToWord, HumanWordLearner, nil, false),
        oh_plls: CommutatorInfo.new(:oh_plls_by_name, Plls, HumanTimeLearner, 3, false),
        plls: CommutatorInfo.new(:plls_by_name, Plls, HumanTimeLearner, 3, false),
        oh_colls: CommutatorInfo.new(:oh_plls_by_name, Colls, HumanTimeLearner, 3, false),
        colls: CommutatorInfo.new(:plls_by_name, Colls, HumanTimeLearner, 3, false),
        olls_plus_cp: CommutatorInfo.new(:olls_plus_cp, OllsPlusCp, HumanTimeLearner, 3, false)
      }.freeze

      def self.default_options
        options = OpenStruct.new
        options.new_item_boundary = 11
        options.commutator_info = COMMUTATOR_TYPES['corners']
        options.restrict_letters = nil
        options.exclude_letters = []
        options.letter_scheme = BernhardLetterScheme.new
        options.color_scheme = ColorScheme::BERNHARD
        options.restrict_colors = options.color_scheme.colors
        options.picture = false
        options.mute = false
        options.buffer = nil
        options.test_comms_mode = :ignore
        options
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.parse(args)
        options = default_options

        # rubocop:disable Metrics/BlockLength
        CubeTrainerOptionsParser.new(options) do |opts|
          opts.on_size

          opts.on(
            '-c', '--commutator_type TYPE', COMMUTATOR_TYPES,
            'Use the given type of commutators for training.'
          ) do |c|
            options.commutator_info = c
            if options.cube_size.nil? && !c.default_cube_size.nil?
              options.cube_size = c.default_cube_size
            end
          end

          opts.on(
            '-t', '--test_comms_mode [MODE]', CommutatorHintParser::TEST_COMMS_MODES,
            'Test commutators mode at startup.'
          ) do |t|
            options.test_comms_mode = t
          end

          opts.on('-i', '--memo_time_s TIME', Float, 'The desired memo time.') do |i|
            unless i.positive?
              warn 'Memo time has to be positive.'
              exit(1)
            end

            options.memo_time_s = i
          end

          opts.on(
            '-b', '--buffer BUFFER', /\w+/,
            'Buffer to use instead of the default one.'
          ) do |b|
            options.buffer = b
          end

          opts.on(
            '-x', '--restrict_colors COLORLIST', /[yrbgow]+/,
            'Restrict colors to find a layer for.'
          ) do |colors|
            options.restrict_colors =
              colors.each_char.map do |c|
                options.color_scheme.colors.find { |o| o.to_s[0] == c }
              end
          end

          opts.on(
            '-p', '--[no-]picture',
            'Show a picture of the cube instead of the letter pair.'
          ) do |p|
            options.picture = p
          end

          opts.on(
            '-n', '--new_item_boundary INTEGER', Integer,
            'Number of repetitions at which we stop considering an item a "new item" that ' \
            'needs to be repeated occasionally.'
          ) do |int|
            options.new_item_boundary = int
          end

          opts.on('-m', '--[no-]mute', 'Mute (i.e. no audio).') do |m|
            options.mute = m
          end

          opts.on(
            '-r', '--restrict_letters LETTERLIST', /\w+/,
            'List of letters to which the commutators should be restricted.',
            '  (Only uses commutators that contain at least one of the given ' \
            'letters)'
          ) do |letters|
            options.restrict_letters = letters.downcase.split('')
          end

          opts.on(
            '-e', '--exclude_letters LETTERLIST', /\w+/,
            'List of letters which should be excluded for commutators.',
            '  (Only uses commutators that contain none of the given letters)'
          ) do |letters|
            options.exclude_letters = letters.downcase.split('')
          end
        end.parse!(args)
        # rubocop:enable Metrics/BlockLength
        unless options.commutator_info
          warn 'Option --commutator_type is required.'
          exit(1)
        end

        options
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end