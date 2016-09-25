# Walle

Simple DSL for building Slack bots.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'walle'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install walle
```

## Usage


Example bot class:

```ruby
class Robot < Walle::Robot
  # Use middleware for all events
  use Walle::Middlewares::Logger, Logger.new(STDOUT)

  # catch `hello` events
  hello { |env| }

  # catch `start` events
  start { |env| }

  # catch `message` events
  message { |env| }

  # catch `close` events
  close { |env| }

  # catch `closed` events
  closed { |env| }

  routes do
    # Use middleware ONLY for routes
    use SomeCustomMidleware, 'arg1', 'arg2'

    # Prefix all matches with bot name, eg. <@U2EU6KZDW>
    direct do
      # Matches string like "<@U2EU6KZDW> convert 10000 RUB into EUR"
      match /convert\s+(?<amount>\d+)\s*(?<from>[A-Z]{3})\s+into\s+(?<to>[A-Z]{3})/ do |env|
        # env.event   - :message
        # env.client  - Slack::RealTime::Client
        # env.data    - Event data (it can contain extra data that can be added in middlewares)
        # env.matches - MatchData object with captured values:
        #   - amount: 10000
        #   - from: RUB
        #   - to: EUR
      end
    end

    # Add prefix to all routes
    prefix 'Hi (?<name>\w+),\s+' do
      # Matches string like "Hi Dave, blah blah blah" and "Dave" will be captured in env.matches[:name]
      match /.*/, controller: GreetingsController
    end
  end
end
```

Run bot: `Robot.run`, `Robot.run(async: true)`.

Also you can manually create the bot and give to him a prepared client:

```ruby
client = Slack::RealTime::Client.new(options)
robot  = Robot.new(client, async: true)
robot.run
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/undr/walle.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
