# frozen_string_literal: true

# Model for letter scheme mappings that form a letter scheme together.
class LetterSchemeMapping < ApplicationRecord
  include PartHelper

  belongs_to :letter_scheme
  attribute :part, :part

  validates :part, presence: true
  validates :letter, presence: true, length: { is: 1 }
  validates :part, uniqueness: { scope: :letter_scheme }

  def part_type
    part.class
  end

  def to_simple
    {
      part: part_to_simple(part),
      letter: letter
    }
  end
end
