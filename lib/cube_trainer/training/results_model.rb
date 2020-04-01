# frozen_string_literal: true

module CubeTrainer
  module Training
    # Class that handles storing and querying results.
    class ResultsModel
      def initialize(mode)
        @mode = mode
        @results = mode.inputs.map(&:result).compact
        @result_listeners = []
      end

      attr_reader :mode, :results

      def add_result_listener(listener)
        @result_listeners.push(listener)
      end

      def record_result(partial_result, input)
        raise ArgumentError unless partial_result.is_a?(PartialResult)

        result = input.from_partial(@mode, partial_result)
        results.unshift(result)
        result.save!
        @result_listeners.each { |l| l.record_result(result) }
      end

      def delete_after_time(timestamp)
        inputs.each { |r| r.destroy if r.created_at + r.time_s > timestamp }
        results.delete_if { |r| r.created_at + r.time_s > timestamp }
        @result_listeners.each { |l| l.delete_after_time(@mode, timestamp) }
      end

      def last_word_for_input(input_representation)
        result = results.select do |r|
          r.input_representation == input_representation
        end.max_by(&:created_at)
        result&.word
      end

      def inputs_for_word(word)
        results.select { |r| r.word == word }.map(&:input_representation).uniq
      end
    end
  end
end
