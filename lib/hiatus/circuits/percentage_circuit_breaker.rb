# frozen_string_literal: true

module Hiatus
  module Circuits
    class PercentageCircuitBreaker < Hiatus::CircuitBreaker
      def initialize(threshold: nil, half_open_interval: nil)
        threshold = Hiatus::PercentageThreshold.new threshold
        super threshold: threshold, half_open_interval: half_open_interval
      end
    end
  end
end
