require 'net/http'

RSpec.describe 'Health Checking Example' do
  it 'works' do
    service = double()
    allow(service).to receive(:call) { raise Net::ReadTimeout }

    circuit_breaker = Hiatus::CircuitBreaker.new
    health_checker = Hiatus::HealthChecker.new 5

    5.times do
      expect {
        circuit_breaker.run { service.call }
      }.to raise_error Net::ReadTimeout
    end

    expect(circuit_breaker.state).to eq :open

    # begin
    #   circuit_breaker.run { service.call }
    # rescue Hiatus::CircuitBrokenError => e
    #   timestamp = e.till
    # end

    # thread = Thread.new do
    #   true while Time.now < timestamp

    #   circuit_breaker.run { 'works!' }
    #   p "thread", circuit_breaker.state
    # end



    # Timecop.travel(timestamp + 5)

    # sleep 0.05 while thread.alive?
  
    # state = circuit_breaker.state

    # expect(state).to eq(:closed)
  end
end
