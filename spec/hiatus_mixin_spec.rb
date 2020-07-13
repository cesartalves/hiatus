RSpec.describe Hiatus::Mixin do

  class Service
    include Hiatus::Mixin

    circuit_factory -> { Hiatus::Circuits::CountCircuitBreaker.new threshold: 3 }

    circuit_protected def call
      raise 'Error'
    end

  end

  it "works" do
    instance = Service.new
    2.times do
      instance.call rescue nil
    end

    expect(instance.send(:circuit_breaker)).to be_closed

    1.times do
      instance.call rescue nil
    end

    expect(instance.send(:circuit_breaker)).to be_open

    expect {
      instance.call
    }.to raise_error Hiatus::CircuitBrokenError
  end
end