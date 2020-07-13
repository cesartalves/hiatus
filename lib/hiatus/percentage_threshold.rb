module Hiatus
  class PercentageThreshold

    DEFAULT_PERCENTAGE = 0.5

    def initialize(failure_percentage = DEFAULT_PERCENTAGE)
      @failure_percentage = failure_percentage
      @failure_count = 0.0
      @total_calls = 0.0
    end

    def increment
      @failure_count += 1
    end

    def touch
      @total_calls += 1
    end

    def reset
      @failure_count = 0
      @total_calls = 0
    end

    def reached?
      @failure_count / @total_calls > @failure_percentage
    end

  end
end