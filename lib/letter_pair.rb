require 'cube'

module CubeTrainer

  # Called LetterPair for historical reasons, but actually can contain any number of letters.
  class LetterPair
  
    SEPARATOR = ' '

    def initialize(letters)
      raise ArgumentError, "Invalid letter pair length for letter pair #{letters.join(" ")}." unless 1 <= letters.length
      raise ArgumentError, "Invalid letter '#{SEPARATOR}' in letter pair #{letters.join(" ")}." if letters.include?(SEPARATOR)
      @letters = letters
    end
  
    attr_reader :letters
  
    # Encoding for YAML (and possibly others)
    def encode_with(coder)
      coder['letters'] = @letters
    end
  
    # Construct from data stored in the db.
    def self.from_raw_data(data)
      LetterPair.new(data.split(SEPARATOR))
    end
  
    # Serialize to data stored in the db.
    def to_raw_data
      @letters.join(SEPARATOR)
    end
  
    def eql?(other)
      self.class.equal?(other.class) && @letters == other.letters
    end
  
    alias == eql?
  
    def hash
      @letters.hash
    end
  
    def to_s
      @to_s ||= letters.collect { |l| l.capitalize }.join(SEPARATOR)
    end
  
    def regexp
      @regexp ||= Regexp.new('^' + @letters.join('.*'), Regexp::IGNORECASE)
    end
  
    def matches_word?(word)
      word =~ regexp
    end
  
    def inverse
      LetterPair.new(@letters.reverse)
    end
  end

end
