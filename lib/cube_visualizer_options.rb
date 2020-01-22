require 'color_scheme'
require 'cube_trainer_options_parser'
require 'algorithm'
require 'parser'
require 'ostruct'

module CubeTrainer

  class CubeVisualizerOptions

    def default_options
      options = OpenStruct.new
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.algorithm = Algorithm.empty
      options
    end

    def self.parse(args)
      options = default_options
      
      CubeTrainerOptionsParser.new(options) do |opts|
        opts.on_size
        opts.on_output('image file')

        opts.on('-a', '--algorithm [ALGORITHM]', String, 'Algorithm to be applied before visualization.') do |a|
          options.algorithm = parse_algorithm(a)
        end
      end.parse!(args)
      options
    end

  end

end
