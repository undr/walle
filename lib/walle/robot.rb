require 'walle/middlewares/helper'
require 'walle/middlewares/builder'
require 'walle/middlewares/logger'
require 'walle/robot/router'
require 'walle/robot/definitions'
require 'walle/controller'

module Walle
  class Robot
    Environment = Struct.new(:event, :client, :data, :matches)

    class_attribute :_definitions, instance_writer: false
    self._definitions = Definitions::Stack.new

    class << self
      delegate *Definitions::METHODS, to: :_definitions

      def inherited(subclass)
        subclass._definitions.push(Definitions.new)
        super
      end

      def run(options = {}, &block)
        client   = Slack::RealTime::Client.new(options)
        instance = new(client, options)
        instance.run(&block)
        instance
      end
    end

    attr_reader :client

    def initialize(client, options = {})
      @client  = client
      @async   = !!options.delete(:async)
      @options = options
    end

    def run(&block)
      _definitions.apply_to(client)
      async? ? client.start_async(&block) : client.start!(&block)
    end

    def stop
      client.stop!
    end

    def started?
      client.started?
    end

    def async?
      @async
    end
  end
end
