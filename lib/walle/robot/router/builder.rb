module Walle
  class Robot
    class Router
      class Builder
        ROUTE_OPTIONS = %i{controller prefix direct delimiter}

        instance_methods.each do |method|
          undef_method(method) if method !~ /^(__|instance_eval|class|object_id|with_options|singleton_class|inspect)/
        end

        attr_reader :router

        def initialize(router)
          @router = router
        end

        def pattern(*patterns)
        end

        def use(middleware, *args)
          router.use(middleware, *args)
        end

        def command(*commands, &block)
          arguments = commands.extract_options!
          options   = arguments.extract!(*ROUTE_OPTIONS)

          regexp = { command: /#{commands.join(?|)}/ }.merge(arguments).map do |name, regexp|
            regexp.is_a?(Regexp) ? "(?<#{name}>#{regexp.source})" : "#{regexp}"
          end.join(options[:delimiter].try(:source) || '\s+')

          match(Regexp.new(regexp), options, &block)
        end

        def direct(&block)
          with_options(direct: true, &block)
        end

        def prefix(value, &block)
          with_options(prefix: value, &block)
        end

        def match(regexp, options = {}, &block)
          controller = extract_controller(options, &block)
          router.routes << Route.new(options.slice(*ROUTE_OPTIONS).merge(controller: controller, regexp: regexp))
        end

        def default(options = {}, &block)
          controller = extract_controller(options, &block)
          router.default[!!options[:direct]] = Route.new(options.slice(*ROUTE_OPTIONS).merge(controller: controller))
        end

        def build(block)
          instance_eval(&block)
        end

        private

        def extract_controller(options, &block)
          block_given? ? block : options[:controller].presence || DEFAULT_CONTROLLER
        end
      end
    end
  end
end
