module Hiatus
  class CircuitBrokenError < StandardError; end

  class CircuitBreaker

    DEFAUTS = {
      threshold: 5,
      half_open_interval: 5
    }

    DEFAULT_THRESHOLD = CountThreshold.new DEFAUTS[:threshold]

    attr_reader :state

    def initialize(threshold: nil, half_open_interval: nil)
      @threshold = threshold || DEFAULT_THRESHOLD
      @half_open_interval = half_open_interval || DEFAUTS[:half_open_interval]

      @state = state
    end

    def run &block

      raise CircuitBrokenError if open? && !reached_retrial_threshold?

      begin
        call_with_circuit_state_changes &block
      rescue => e
        increment_failure_count_and_trip_if_threshold_exceeded
        raise $!
      end
    end

    def call_with_circuit_state_changes
      @threshold.touch
      yield if block_given?
      @threshold.reset if half_open?
      close
    end

    def increment_failure_count_and_trip_if_threshold_exceeded
      increment_failure_count
      trip_if_threshold_exceeded
    end

    def increment_failure_count; @threshold.increment; end

    def trip_if_threshold_exceeded
      @state = :open if @threshold.reached?

      refresh_last_failure_timestamp
    end

    def open?
      state == :open
    end

    def closed?
      state == :closed
    end

    def close
      @state = :closed
      @threshold.reset
      last_failure_timestamp = nil
    end

    def half_open?
      open? && reached_retrial_threshold?
    end

    protected

    def refresh_last_failure_timestamp
      @last_failure_timestamp = Time.now
    end

    def reached_retrial_threshold?
      last_failure_timestamp && Time.now - last_failure_timestamp > @half_open_interval
    end

    attr_accessor :last_failure_timestamp

  end
end
