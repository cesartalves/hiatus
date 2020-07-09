# Hiatus

Dead simple circuit breaker pattern implementation. For future reference and talks :)

--

## Installation

Add `gem 'hiatus', git: https://github.com/cesartalves/hiatus` to your Gemfile

## Usage

Once threshold is reached, will raise a `Hiatus:CircuitBrokenError` till `half_open_interval` passes. Then, it will half-open: a failed call trips the circuit again, a successful call closes it.

```ruby
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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/circuit_breaker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/circuit_breaker/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CircuitBreaker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/circuit_breaker/blob/master/CODE_OF_CONDUCT.md).
