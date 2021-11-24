# frozen_string_literal: true

module Hiatus
  class BaseThreshold
    def initialize(threshold = 5)
      @threshold = threshold
      @failure_count = 0
    end

    def increment
      @failure_count += 1
    end

    def reached?; end
    def reset; end
    def touch; end
  end
end
