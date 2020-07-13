require 'timecop'
require 'httparty'

RSpec.describe Hiatus::Circuits::PercentageCircuitBreaker do

  let!(:threshold) { 0.5 }

  let(:open_circuit) {
    instance = described_class.new(threshold: threshold)

    2.times do
     instance.run { raise 'SomeError'} rescue nil
    end

    instance
  }

  context "when circuit is closed" do

    let(:circuit_breaker) { described_class.new(threshold: threshold)}

    it "will open if threshold is reached" do

      calls = 2

      calls.times do
        circuit_breaker.run { }
      end

      (calls + 1).times do
        begin
          circuit_breaker.run { raise Net::ReadTimeout }
        rescue => e
        end
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

        expect { circuit_breaker.run { raise 'Error' } }.to raise_error Hiatus::CircuitBrokenError
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
