module Hiatus
  class CountThreshold

    def initialize(threshold = 5)
      @threshold = threshold
      @failure_count = 0
    end

    def increment
      @failure_count += 1
    end

    def reached?
      @failure_count >= @threshold
    end

    def reset
      @failure_count = 0
    end

    def touch; end;
  end
end