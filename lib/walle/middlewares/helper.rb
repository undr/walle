module Walle
  module Middlewares
    module Helper
      def use(middleware, *args)
        @middlewares ||= Builder.new
        @middlewares.use(middleware, *args)
      end

      private

      def run_middlewares(env, &block)
        @middlewares.to_app(block).call(env)
      end
    end
  end
end
