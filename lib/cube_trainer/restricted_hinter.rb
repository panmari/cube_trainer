module CubeTrainer

  class RestrictedHinter

    def initialize(inputs, hinter)
      raise TypeError unless inputs.respond_to?(:include?)
      raise TypeError unless hinter.respond_to?(:hints) && hinter.respond_to?(:entries)
      @inputs = inputs
      @hinter = hinter
    end

    attr_reader :inputs

    def hints(input)
      raise unless in_domain?(input)
      @hinter.hints(input)
    end

    def in_domain?(input)
      @inputs.include?(input)
    end

    def entries
      @hinter.entries.select { |a, b| in_domain?(a) }
    end
  end
  
end
