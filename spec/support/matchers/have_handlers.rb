module Walle
  module Matchers
    class HaveHandlers
      def initialize
      end

      def for(event)
        @event = event
        self
      end

      def include(*handlers)
        @handlers = handlers
        self
      end

      def matches?(object)
        if @handlers
          (@handlers - object.handlers(@event)).empty?
        else
          !object.handlers(@event).empty?
        end
      end

      def failure_message
        event = @event ? " for `#{@event}` event" : ''
        "expected the object to have handlers#{event} but it doesn't have any\n"
      end

      def failure_message_when_negated
        event = @event ? " for `#{@event}` event" : ''
        "expected the #{type} body to not have handlers#{event} but it has.\n"
      end

      def description
        event = @event ? " for `#{@event}` event" : ''
        "have handlers#{event}"
      end
    end

    def have_handlers
      HaveHandlers.new
    end
  end
end
