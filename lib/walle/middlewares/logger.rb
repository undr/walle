module Walle
  module Middlewares
    class Logger
      attr_reader :env, :logger, :options

      def initialize(env, logger, options = {})
        @env = env
        @logger = logger
        @options = options
      end

      def before
        logger.info("[#{env.event}] - #{env.data.to_json}")
      end
    end
  end
end
