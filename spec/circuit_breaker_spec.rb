# frozen_string_literal: true

require 'timecop'
require 'httparty'
require 'open-uri'

RSpec.describe Hiatus::CircuitBreaker do
  described_class.prepend Hiatus::ThreadSafe

  let!(:threshold) { Hiatus::CountThreshold.new 2 }

  let(:open_circuit) do
    described_class.new(threshold: threshold).tap do |instance|
      instance.instance_eval do
        3.times do
          increment_failure_count
          trip_if_threshold_reached
        end
      end
    end
  end

  context 'when circuit is closed' do
    let(:circuit_breaker) { described_class.new(threshold: threshold) }

    it 'will open if threshold is reached' do
      2.times do
        circuit_breaker.run { raise Net::ReadTimeout }
      rescue StandardError => e
      end

      expect(circuit_breaker).to be_open
      expect { circuit_breaker.run { } }.to raise_error Hiatus::CircuitBrokenError
    end
  end

  context 'when circuit is open' do
    let!(:circuit_breaker) { open_circuit }

    it 'will half-open if interval elapses' do
      Timecop.freeze(Time.now + 5) do
        expect(circuit_breaker).to be_half_open
      end
    end

    context 'when circuit is half-open' do
      let!(:circuit_breaker) { open_circuit }

      it "will open again if it's half-open and there's another failure" do
        Timecop.freeze(Time.now + 5) do
          expect(circuit_breaker).to be_half_open

          expect { circuit_breaker.run { raise 'Error' } }.to raise_error RuntimeError

          expect(circuit_breaker).to be_open

          expect { circuit_breaker.run { raise 'Error' } }.to raise_error Hiatus::CircuitBrokenError
        end
      end
    end

    it 'will open if the call succeeds' do
      Timecop.freeze(Time.now + 5) do
        expect(circuit_breaker).to be_half_open

        circuit_breaker.run { }
        expect(circuit_breaker).to be_closed
      end
    end
  end

  context 'thread safety' do
    let!(:circuit_breaker) do
      described_class.new(threshold: threshold).tap do |cb|
        1.times do
          cb.run { raise Net::ReadTimeout } rescue nil
        end
      end
    end

    it 'successfully update counters when running concurrently' do
      errors = []

      5.times.map do
        Thread.new do
          begin
            circuit_breaker.run { URI.open('http://httpstat.us/500') }
          rescue StandardError => e
            errors << e.class.to_s
          end

          expect(circuit_breaker).to be_open
        end
      end.each(&:join)

      # We should get an HTTP Error only once, and then several CircuitBrokerError
      # if we get more than one HTTP Error it means that we're getting a race condition!
      expect(errors.filter { |error| error == 'OpenURI::HTTPError' }.count).to eq 1
    end
  end
end
