# Hiatus

* *noun:*
  + *a pause or gap in a sequence, series, or process.*
  + *A temporary gap, pause, break*


[![Maintainability](https://api.codeclimate.com/v1/badges/f525ee829216ceed6006/maintainability)](https://codeclimate.com/github/cesartalves/hiatus/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f525ee829216ceed6006/test_coverage)](https://codeclimate.com/github/cesartalves/hiatus/test_coverage)
[![Build Status](https://travis-ci.org/cesartalves/hiatus.svg)](https://travis-ci.org/cesartalves/hiatus)

Dead simple circuit breaker pattern implementation.

Currently this is an unambitious project for future reference and talks. Thought the pattern was interesting and wanted to give it a shot :)

--

## Introduction

This pattern helps applications which deal with calls to remote services. When they're unavailable, it prevents repeated calls which may cause cascading failure.

Here is a great article about it: https://martinfowler.com/bliki/CircuitBreaker.html

## Installation

Add `gem 'circuit-hiatus'` to your Gemfile and `bundle install`, or `gem install circuit-hiatus`

## Usage

Once threshold is reached, the circuit will raise a `Hiatus:CircuitBrokenError` until `half_open_interval` passes. Then, it will half-open: a failed call trips the circuit again, a successful call closes it.

```ruby

require 'hiatus' # not circuit-hiatus!

threshold = Hiatus::CountThreshold.new 5 # will be broken on the 5th failed attempt

circuit_breaker = Hiatus::CircuitBreaker.new threshold: threshold, half_open_interval: 60 # after 60 seconds, circuit is apt to make calls again

5.times do
  circuit_breaker.run do
    begin
    # Http call raising error
    rescue => e
    end
  end
end

circuit_breaker.run do
  # any call
end # => Hiatus:CircuitBrokenError

```

You can also include a Mixin in your class, since apparently this is what the ruby kids like. No idea why you'd like to tie your code to my little gem, but here it goes:

```ruby
require 'hiatus'

class Service

include Hiatus::Mixin

# this gives you great flexiblity on which circuit to use
# you can even have your classes sharing the same circuit breaker :)
circuit_factory -> { Hiatus::Circuits::CountCircuitBreaker.new threshold: 3 }

circuit_protected def call
  raise 'Error'
end

# Check `spec/hiatus_mixin_spec.rb` for the full example

```

To configure a default factory:

```ruby

Hiatus::Mixin.config do |c|
  c.default_circuit_factory = { Hiatus::Circuits::PercentageCircuitBreaker.new threshold: 0.5 }
end

```

*Available Circuit types*

- `Hiatus::Circuits::PercentageCircuitBreaker` => shorthand for circuit with threshold= `Hiatus::CountThreshold.new`. Opens once requests fails enough times

- `Hiatus::Circuits::CountCircuitBreaker` => shorthand for circuit with threshold=  `Hiatus::PercentageThreshold.new`. Opens once failure percentage passes the given threshold

## Advanced configuration

You can easily create new instances of Threshold, so that they can be stored anywhere (database, redis, your dog's house - anything that responds to the interface), effectively creating a circuit breaker that can be used across applications:

```ruby

class RedisThreshold < CountThreshold
  def initialize(options)

  def increment
    super
    serialize
  end

  def reached?
    failure_count, threshold = *deserialize
    failure_count >= threshold
  end

  def reset
    super
    serialize
  end

  private

  def deserialize
    # get stuff from redis here
  end

  def serialize
    # put stuff into redis here
  end
end

threshold = RedisThreshold.new(url:, threshold: 15)

redis_cb = Hiatus::CircuitBreaker.new threshold: threshold, half_open_interval: 90

```

You can find an example of a Threshold stored in a file in extras/file_count_threshold.rb

## Health-Checking

You can use the `HealthCheck` class to verify the circuit's health on a given period of time in seconds


```ruby
  checker = Hiatus::HealthCheck.new(30).tick!


  checker.healthy?(circuit)

```
## Possible improvements

- Figure out why travis badge says error even though the build is passing ¬ ¬'

## Contributing

PRs are welcome :)
- PRs must be 100% test-covered
- PRs must please my code aesthetical preferences

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CircuitBreaker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cesartalves/hiatus/blob/master/CODE_OF_CONDUCT.md).
