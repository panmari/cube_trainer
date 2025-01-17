# frozen_string_literal: true

# Result of giving one task to the learner and judging their performance.
# TODO Migrate from LegacyResult in lib/ to this.
class Result < ApplicationRecord
  POSITIVE_INTEGER = {
    only_integer: true,
    greater_than_or_equal_to: 0
  }.freeze

  belongs_to :input
  attribute :old_mode, :symbol
  attribute :old_input_representation, :input_representation

  validates :time_s, presence: true, numericality: { greater_than: 0 }
  validates :failed_attempts, numericality: POSITIVE_INTEGER
  validates :success, inclusion: [true, false]
  validates :num_hints, numericality: POSITIVE_INTEGER
  validates :input_id, presence: true, uniqueness: true

  def self.from_input_and_partial(input, partial_result)
    new(
      input: input,
      time_s: partial_result.time_s,
      failed_attempts: partial_result.failed_attempts || 0,
      word: partial_result.word,
      success: partial_result.success.nil? ? true : partial_result.success,
      num_hints: partial_result.num_hints || 0
    )
  end

  delegate :input_representation, to: :input

  def to_dump
    {
      time_s: time_s,
      failed_attempts: failed_attempts,
      word: word,
      success: success,
      num_hints: num_hints,
      created_at: created_at
    }
  end

  def time
    time_s&.seconds
  end
end
