module Hiatus
  class HealthChecker
    def initialize(period = 30)
      @period = period
    end

    def tick!(circuit)
      Thread.new do
        while true
          # TODO: maybe we need a scheduler across the library to avoid creating tons of threads for multiple CircuitBreakers?
          begin
            circuit.send(:call_with_circuit_state_changes)
          rescue StandardError => e
            circuit.send(:refresh_last_failure_timestamp)
          end

          sleep @period
        end
      end
    end

    def healthy?(circuit)
      circuit.closed?
    end
  end
end
