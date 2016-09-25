module Walle
  class Robot
    class Definitions
      EVENTS = %i{start hello close closed message}
      METHODS = EVENTS + %i{use routes pattern}

      class Stack
        delegate *Definitions::METHODS, to: :current

        def initialize
          @entities = []
        end

        def push(definitions)
          @entities << definitions
        end

        def current
          @entities.last
        end

        def apply_to(client)
          @entities.each do |definitions|
            definitions.apply_to(client)
          end
        end
      end

      include ::Walle::Middlewares::Helper

      attr_reader :all_handlers

      def initialize
        @all_handlers = Hash.new { |h, k| h[k] = [] }
      end

      EVENTS.each do |event|
        define_method(event) do |&handler|
          handlers(event) << handler
        end
      end

      def routes(&block)
        router = Router.new(&block)
        message { |env| router.call(env) }
      end

      def apply_to(client)
        all_handlers.each do |event, event_handlers|
          event_handlers.each do |handler|
            client.on(event) do |data|
              handle_event(environment(event, client, data))
            end
          end
        end
      end

      def handlers(event = nil)
        return all_handlers[event] if event
        all_handlers.values.flatten.uniq
      end

      private

      def environment(event, client, data)
        Environment.new(event, client, data)
      end

      def handle_event(env)
        run_middlewares(env) do |env|
          handler.call(env)
        end
      end
    end
  end
end
