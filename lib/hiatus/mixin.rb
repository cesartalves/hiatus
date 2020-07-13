module Hiatus
  module Mixin

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def circuit_factory(callable)
        @@circuit_factory = callable
      end

      def circuit_break(method)
        unbounded_method_to_decorate = instance_method method

        define_method :circuit_breaker do
          @_circuit_breaker_
        end

        private :circuit_breaker

        define_method method do |*args, &block|
          @_circuit_breaker_ ||= @@circuit_factory[]

          @_circuit_breaker_.run do
            unbounded_method_to_decorate.bind(self)[*args, &block]
          end
        end
      end

      alias_method :circuit_protected, :circuit_break

    end

  end
end