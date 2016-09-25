module Walle
  module Middlewares
    class Builder
      class Proxy
        attr_reader :target_class, :app, :args, :block

        def initialize(target_class, app, *args, &block)
          @target_class, @app, @args, @block = target_class, app, args, block
        end

        def call(env)
          with_env(env) do |target|
            target.before if target.respond_to?(:before)
            app.call(env)
            target.after if target.respond_to?(:after)
          end
        end

        private

        def with_env(env)
          yield target_class.new(env, *args, &block)
        end
      end

      def initialize(default_app = nil, &block)
        @use, @run = [], default_app
        instance_eval(&block) if block_given?
      end

      def use(middleware, *args, &block)
        @use << ->(app){ Proxy.new(middleware, app, *args, &block) }
      end

      def to_app(app)
        app ||= @run
        fail 'missing run statement' unless app
        @use.reverse.inject(app){|a, e| e[a] }
      end

      def call(env)
        to_app.call(env)
      end
    end
  end
end
