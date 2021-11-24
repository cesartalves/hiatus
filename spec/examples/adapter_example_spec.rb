# frozen_string_literal: true

RSpec.describe 'Adapter example' do
  it 'works' do
    service = double
    allow(service).to receive(:call) { raise Net::ReadTimeout }

    circuit_breaker = Hiatus::CircuitBreaker.new

    adapter = double
    allow(adapter).to receive(:call) { circuit_breaker.run { service.call } }

    5.times do
      expect do
        adapter.call
      end.to raise_error Net::ReadTimeout
    end

    expect do
      adapter.call
    end.to raise_error Hiatus::CircuitBrokenError
  end
end
