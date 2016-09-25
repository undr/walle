module Slack
  module RealTime
    class MockClient
      attr_reader :all_handlers

      def initialize
        @all_handlers = Hash.new { |h, k| h[k] = [] }
      end

      def on(event, &block)
        handlers(event) << block
      end

      def handlers(event = nil)
        return all_handlers[event] if event
        all_handlers.values.flatten.uniq
      end
    end
  end
end
