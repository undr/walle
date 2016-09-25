# TODO: Add support of this: https://github.com/andrewberls/regularity
module Walle
  class Robot
    class Router
      class Route
        attr_reader :controller, :regexp, :options

        class Mutator
          attr_reader :env, :regexp, :options

          def initialize(env, regexp, options = {})
            @env = env
            @regexp = regexp
            @options = options
          end
        end

        class Prefix < Mutator
          def mutate
            return regexp unless prefix

            if regexp
              Regexp.new("#{prefix}#{regexp.source}")
            else
              Regexp.new(prefix)
            end
          end

          def prefix
            return if options[:prefix] === false
            options[:prefix] || '.*'
          end
        end

        class Direct < Mutator
          def mutate
            return regexp unless direct?

            robot_name = env.client.self.id
            expr = regexp || /.*/
            Regexp.new("<@#{robot_name}>\\s+#{expr.source}")
          end

          def direct?
            options[:direct]
          end
        end

        MUTATORS = [Direct, Prefix]

        def initialize(controller:, regexp: nil, **options)
          @controller = controller
          @options = options
          @regexp = regexp
        end

        def match?(env)
          expr = final_regexp(env)
          !!expr.match(env.data.text)
        end

        def call(env)
          expr = final_regexp(env)
          env.matches = expr.match(env.data.text) if expr
          cntrl.respond_to?(:call) ? cntrl.call(env) : cntrl.new(env).call
        end

        alias :cntrl :controller

        private

        def final_regexp(env)
          MUTATORS.reduce(regexp) { |result, mutator| mutator.new(env, result, options).mutate }
        end
      end
    end
  end
end
