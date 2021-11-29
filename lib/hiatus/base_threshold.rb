# frozen_string_literal: true

module Hiatus
  # describes a basic interface for a Threadshold
  # a custom threshold might be created by conforming to this interface
  class BaseThreshold
    def initialize(threshold = 5)
      @threshold = threshold
      @failure_count = 0
    end

    # called when the CircuitBreaker finds an error
    def increment
      @failure_count += 1
    end

    # whether the threadshold for opening the circuit has been reached
    def reached?; end
    # reset threshold (when closing circuit)
    def reset; end
    # perform any operation when an operation success (eg, incrementing number of calls)
    def touch; end
  end
end
