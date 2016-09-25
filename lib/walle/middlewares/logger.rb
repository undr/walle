module Walle
  module Middleware
    class Logger
      def initialize(env, logger, options = {})
        @env = env
        @logger = logger
        @options = options
      end

      def before
        logger.log("[#{event}] - #{data.inspect}")
      end
    end
  end
end
