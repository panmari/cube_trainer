require 'sampling_helper'
require 'cube_trainer_error'

module CubeTrainer

  class SamplingError < CubeTrainerError
  end

  class Sampler
    def random_item
      raise NotImplementedError
    end

    def ready?
      raise NotImplementedError
    end
  end

  class CombinedSampler < Sampler

    include SamplingHelper
    SubSampler = Struct.new(:subsampler, :weight)
    
    def initialize(subsamplers)
      subsamplers.each do |s|
        raise TypeError, "#{s.inspect} is not a subsampler." unless s.is_a?(SubSampler)
        raise TypeError unless s.weight.is_a?(Numeric)
        raise ArgumentError unless s.weight > 0.0
        raise TypeError unless s.subsampler.is_a?(Sampler)
      end
      @subsamplers = subsamplers
    end

    def random_item
      subsamplers = ready_subsamplers
      raise SamplingError if subsamplers.empty?
      sample_by(subsamplers) { |s| s.weight }.subsampler.random_item
    end

    def ready_subsamplers
      @subsamplers.select { |s| s.subsampler.ready? }
    end

    def ready?
      !ready_subsamplers.empty?
    end

  end
  
  class PrioritizedSampler < Sampler

    def initialize(subsamplers)
      raise TypeError unless subsamplers.all? { |s| s.is_a?(Sampler) }
      @subsamplers = subsamplers
    end

    def random_item
      @subsamplers.each do |s|
        return s.random_item if s.ready?
      end
      raise
    end

    def ready?
      @subsamplers.any? { |s| s.ready? }
    end
    
  end
  
  class AdaptiveSampler < Sampler

    include SamplingHelper

    def initialize(items, get_weight_proc)
      raise TypeError unless get_weight_proc.respond_to?(:call)
      @items = items
      @get_weight_proc = get_weight_proc
    end

    def random_item
      ready_items = items
      raise SamplingError if ready_items.empty?
      sample_by(ready_items, &@get_weight_proc)
    end

    def items
      @items.select { |e| @get_weight_proc.call(e) > 0 }
    end
    
    def ready?
      !items.empty?
    end

  end

end