module Hiatus
  module Circuits
    class CountCircuitBreaker < Hiatus::CircuitBreaker
      def initialize(threshold: nil, half_open_interval: nil)
        threshold = Hiatus::CountThreshold.new threshold
        super threshold: threshold, half_open_interval: half_open_interval
      end
    end
  end
end