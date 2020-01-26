require 'cube_trainer/input_sampler'
require 'cube_trainer/restricted_hinter'
require 'cube_trainer/disjoint_union_hinter'
require 'cube_trainer/alg_name'
require 'cube_trainer/alg_hint_parser'
require 'cube_trainer/input_item'
require 'cube_trainer/sequence_hinter'

module CubeTrainer

  class AlgSet

    include StringHelper
    
    def initialize(results_model, options)
      @results_model = results_model
      @options = options
    end

    def input_sampler
      @input_sampler ||= InputSampler.new(input_items, @results_model, goal_badness, @options.verbose, @options.new_item_boundary)
    end

    def goal_badness
      raise NotImplementedError
    end

    def name
      snake_case_class_name(self.class)
    end
    
    def hinter
      @hinter ||= create_hinter
    end

    def create_hinter
      AlgHintParser.maybe_parse_hints(name, @options.verbose)
    end

    def input_items
      @input_items ||= generate_input_items
    end

    def generate_input_items
      state = @options.color_scheme.solved_cube_state(@options.cube_size)
      hinter.entries.map do |name, alg|
        alg.inverse.apply_temporarily_to(state) do
          InputItem.new(name, state.dup)
        end
      end
    end

    def generate_alg_names
      raise NotImplementedError
    end

  end

  class Plls < AlgSet

    def goal_badness
      1.0
    end

  end

  class OllsPlusCp < AlgSet

    def create_hinter
      AlgSequenceHinter.new([oll_hinter, cp_hinter], ' + ')
    end

    def oll_hinter
      @oll_hinter ||= AlgHintParser.maybe_parse_hints('olls', @options.verbose)
    end
    
    def cp_hinter
      @cp_hinter ||= DisjointUnionHinter.new([
                                               RestrictedHinter.new([AlgName.new('Ja'), AlgName.new('Y')], pll_hinter),
                                               RestrictedHinter.new([AlgName.new('solved')], solved_hinter),
                                             ])
    end

    def solved_hinter
      @solved_hinter ||= AlgHinter.new({AlgName.new('solved') => Algorithm.empty})
    end
    
    def pll_hinter
      @pll_hinter ||= AlgHintParser.maybe_parse_hints('plls', @options.verbose)
    end
    
    def goal_badness
      1.0
    end

  end

  class Colls < AlgSet

    def goal_badness
      1.0
    end

  end

end
