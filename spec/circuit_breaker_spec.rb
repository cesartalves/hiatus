require 'timecop'
require 'httparty'

RSpec.describe Hiatus::CircuitBreaker do

  let!(:threshold) { Hiatus::CountThreshold.new 2}

  let(:open_circuit) {
    instance = described_class.new(threshold: threshold)
    instance.instance_eval do
      3.times do
        increment_failure_count
        trip_if_threshold_exceeded
      end
    end

    instance
  }

  context "when circuit is closed" do

    let(:circuit_breaker) { described_class.new(threshold: threshold)}

    it "will open if threshold is reached" do

      2.times do
        expect {
          circuit_breaker.run { raise Net::ReadTimeout }
        }.to raise_error Net::ReadTimeout
      end

      expect(circuit_breaker).to be_open
      expect { circuit_breaker.run { } }.to raise_error Hiatus::CircuitBrokenError
    end
  end

  context "when circuit is open" do
    let!(:circuit_breaker) { open_circuit }

    it "will half-open if interval elapses" do
      Timecop.freeze(Time.now + 5) do
        expect(circuit_breaker).to be_half_open
      end
    end

  context "when circuit is half-open" do

   let(:circuit_breaker) { open_circuit }

    it "will open again if it's half-open and there's another failure" do
      circuit_breaker
        Timecop.freeze(Time.now + 5) do
        expect(circuit_breaker).to be_half_open

        expect { circuit_breaker.run { raise 'Error' } }.to raise_error RuntimeError
        expect(circuit_breaker).to be_open
        end
      end
    end

    it "will open if the call succeeds" do
      circuit_breaker
      Timecop.freeze(Time.now + 5) do
        expect(circuit_breaker).to be_half_open

        circuit_breaker.run {  }
        expect(circuit_breaker).to be_closed
      end
    end
  end
end
