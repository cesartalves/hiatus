module Hiatus
  class CountThreshold < BaseThreshold
    def reached?
      @failure_count >= @threshold
    end

    def reset
      @failure_count = 0
    end
  end
end
