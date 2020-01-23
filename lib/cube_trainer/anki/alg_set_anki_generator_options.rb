require 'cube_trainer/color_scheme'
require 'cube_trainer/algorithm'
require 'cube_trainer/parser'
require 'ostruct'
require 'cube_trainer/cube_trainer_options_parser'

module CubeTrainer

  class AlgSetAnkiGeneratorOptions

    def self.default_options
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.verbose = false
      options.cache = true
      options
    end

    def self.parse(args)
      options = default_options
      
      CubeTrainerOptionsParser.new(options) do |opts|
        opts.on_cache
        opts.on_size
        opts.on_output('anki deck & media output directory')
        opts.on_stage_mask

        opts.on('-a', '--alg_set [ALG_SET]', String, 'Internal algorithm set to be used to generate cards. Either this or --input and --alg_column can be set.') do |a|
          options.alg_set = a
        end

        opts.on('-i', '--input [FILE]', String, 'TSV with an external algorithm set to be used to generate cards. Either this and --alg_column or --alg_set can be set.') do |i|
          options.input = i
        end

        opts.on('-c', '--alg_column [INTEGER]', Integer, 'Column index at which the algorithms are positioned for an external alg set. Starts at 0.') do |c|
          options.alg_column = c
        end

        opts.on('-n', '--name_column [INTEGER]', Integer, 'Column index at which the names are positioned for an external alg set. Starts at 0.') do |n|
          options.name_column = n
        end

        opts.on('-u', '--[no-]auf', 'Add multiple columns for different aufs.') do |u|
          options.auf = u
        end
      end.parse!(args)
      options
    end

  end

end