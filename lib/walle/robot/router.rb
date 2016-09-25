require 'walle/robot/router/route'
require 'walle/robot/router/builder'

module Walle
  class Robot
    class Router
      include ::Walle::Middlewares::Helper

      DEFAULT_CONTROLLER = -> (*_) {}

      attr_reader :routes, :middlewares
      attr_accessor :default

      def initialize(&block)
        @routes = []
        @default = Route.new(regexp: /.*/, controller: DEFAULT_CONTROLLER)
        run_builder!(block)
      end

      def call(env)
        run_middlewares(env) do |env|
          lookup_route(env).call(env)
        end
      end

      private

      def lookup_route(env)
        routes.find { |route| route.match?(env) } || default
      end

      def run_builder!(block)
        Builder.new(self).build(block)
      end
    end
  end
end
