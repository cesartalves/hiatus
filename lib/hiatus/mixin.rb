module Hiatus

  module Mixin

    class << self
      attr_accessor :default_circuit_factory
    end

    def self.config
      yield self
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      class NoCircuitFactoryProvided < StandardError; end

      def circuit_factory(callable)
        @circuit_factory = callable || Hiatus::Mixin.default_circuit_factory
      end

      def _circuit_factory_; @circuit_factory; end

      def circuit_break(method)
        raise NoCircuitFactoryProvided unless @circuit_factory

        unbounded_method_to_decorate = instance_method method

        define_method method do |*args, &block|
          @_circuit_breaker_ ||= self.class._circuit_factory_[]

          @_circuit_breaker_.run do
            unbounded_method_to_decorate.bind(self)[*args, &block]
          end
        end

        define_method :circuit_breaker do
          @_circuit_breaker_
        end

        private :circuit_breaker
      end

      alias_method :circuit_protected, :circuit_break

    end
  end
end