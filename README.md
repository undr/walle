# Walle

[![Build Status](https://travis-ci.org/undr/walle.svg?branch=master)](https://travis-ci.org/undr/walle)

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

    # Equals to match(/(?<command>convert|c)\s+(?<amount>\d+)\s*(?<from>[A-Z]{3})\s+into\s+(?<to>[A-Z]{3})/, controller: CurrencyConvertor)
    command 'convert', 'c', amount: /\d+/, from: /[A-Z]{3}/, into: 'into', to: /[A-Z]{3}/, delimiter: /\s+/, controller: CurrencyConvertor

    # Prefix all matches with bot name, eg. <@U2EU6KZDW>
    direct do
      # Matches string like "<@U2EU6KZDW> convert 10000 RUB into EUR"
      match /convert\s+(?<amount>\d+)\s*(?<from>[A-Z]{3})\s+into\s+(?<to>[A-Z]{3})/ do |env|
        # env.event   - :message
        # env.client  - Slack::RealTime::Client
        # env.data    - Event data (it can contain extra data that can be added in middlewares)
        #   - type: "message"
        #   - channel: "V2T4X87M5"
        #   - user: "Z005UR62C"
        #   - text: "<@U2EU6KZDW> convert 10000 RUB into EUR"
        #   - ts: "1474580776.000003"
        #   - team: "T020WVADD"
        #   - ...
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

Configure Slack client:

```ruby
Slack.configure do |c|
  c.token = 'xxxx-9295867...'
  c.logger = Logger.new(STDOUT)
  c.logger.level = Logger::INFO
end
```

And run the bot: `Robot.run`, `Robot.run(async: true)`.

Also you can manually create the bot and give to him a prepared client:

```ruby
client = Slack::RealTime::Client.new(options)
robot  = Robot.new(client, async: true)
robot.run
```

### Routes

There are three methods for creating routes: `match`, `command` and `default`:

- `match(regexp, options, &block)` - Add route based on regular expression.
  - `regexp` - Regular expression.
  - `options` - Options that adjust route behavior.
    - `prefix` - Add prefix for regular expression, default: `/.*/`. If you want to delete prefix you should use `prefix: false`. `prefix: nil` resets prefix to default value.
    - `direct` -  Uses to create direct route. This’s route that directly address to bot. Messages without `<@botname>` at the start of command will be rejected.
    - `controller` - Any class or object that has `call` method. It can be instance or class method.
  - `block` - It will be used as controller when block is defined.


- `command(*commands, options, block)` - Construct a regular expression using command names and add route using `match`. Check examples.

  ```ruby
  # Equals to: match(/(?<command>convert|c)\s+(?<amount>\d+)\s*(?<from>[A-Z]{3})\s+into\s+(?<to>[A-Z]{3})/, controller: CurrencyConvertor)
  command 'convert', 'c', amount: /\d+/, from: /[A-Z]{3}/, into: 'into', to: /[A-Z]{3}/, delimiter: /\s+/ do |env|
    # "convert 10000 RUB into EUR"
    # `env.matches` is:
    #  - command: "convert"
    #  - amount: 10000
    #  - from: "RUB"
    #  - to: "EUR"
  end
  ```

  Example:

  ```ruby
  command 'add', 'subtract', 'multiply', 'divide', first: /\d+/, second: /\d+/ do |env|
    result = case env.matches[:command]
    when 'add'
      env.matches[:first].to_i + env.matches[:second].to_i
    when 'subtract'
      env.matches[:first].to_i - env.matches[:second].to_i
    when 'multiply'
      env.matches[:first].to_i * env.matches[:second].to_i
    when 'divide'
      env.matches[:first].to_i / env.matches[:second].to_i
    end

    env.client.message(channel: env.data.channel, text: result.to_s)
  end
  ```

- `default(options, block)` - Create default route. It will be used if no one route was matched.

### Controllers

TODO:

### Inheritance

All routes and event handlers from parent class and subclass will be merged when we inherit one bot from another one.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/undr/walle.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
