require 'walle/robot/router/route'
require 'walle/robot/router/builder'

module Walle
  class Robot
    class Router
      include ::Walle::Middlewares::Helper

      DEFAULT_CONTROLLER = -> (*_) {}
      DEFAULT_ROUTER = Route.new(regexp: /.*/, controller: DEFAULT_CONTROLLER)

      attr_reader :routes, :middlewares, :default

      def initialize(&block)
        @routes = []
        @default = { true => DEFAULT_ROUTER, false => DEFAULT_ROUTER }
        run_builder!(block)
      end

      def call(env)
        run_middlewares(env) do |env|
          lookup_route(env).call(env)
        end
      end

      private

      def all_routes
        routes + default.values.uniq
      end

      def lookup_route(env)
        all_routes.find { |route| route.match?(env) } || DEFAULT_ROUTER
      end

      def run_builder!(block)
        Builder.new(self).build(block)
      end
    end
  end
end
