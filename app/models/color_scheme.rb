require 'twisty_puzzles'

class ColorScheme < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user }
  TwistyPuzzles::CubeConstants::FACE_SYMBOLS.each do |f|
    attribute f.downcase, :symbol
    validates f.downcase, presence: true
  end
  validate :colors_valid

  def to_twisty_puzzles_color_scheme
    @to_twisty_puzzles_color_scheme ||=
      begin
        hash = TwistyPuzzles::CubeConstants::FACE_SYMBOLS.map { |f| [f, color(f)] }.to_h
        TwistyPuzzles::ColorScheme.new(hash)
      end
  end

  def self.from_twisty_puzzles_color_scheme(name, color_scheme)
    color_mappings = TwistyPuzzles::CubeConstants::FACE_SYMBOLS.map { |f| [f, color_scheme.color(f)] }
    hash = (color_mappings + [[:name, name]]).to_h
    new(**hash)
  end

  def colors_valid
    TwistyPuzzles::CubeConstants::FACE_SYMBOLS.each { |f| color_valid(f.downcase) }
  end

  def color(face_symbol)
    method(face_symbol).call
  end

  def color_valid(face_symbol)
    c = color(face_symbol)
    return unless TwistyPuzzles::ColorScheme::RESERVED_COLORS.include?(c)

    errors.add(face_symbol, "has reserved color #{c}")
  end
end
