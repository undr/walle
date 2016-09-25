module Walle
  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def call
    end

    protected

    delegate :data, :client, :matches, to: :env

    def message(options)
      options[:channel] ||= data.channel
      client.message(options)
    end

    def typing(options = {})
      options[:channel] ||= data.channel
      client.typing(options)
    end
  end
end
