RSpec.describe Walle::Robot::Router::Builder do
  let(:router) { double(:router) }

  subject { described_class.new(router) }

  describe '#direct' do
    it 'adds direct: true into options for all calls of a method in block' do
      expect(subject).to receive(:match).with(/.*/, direct: true)

      subject.direct { match(/.*/) }
    end
  end

  describe '#prefix' do
    it 'adds prefix into options for all calls of a method in block' do
      expect(subject).to receive(:match).with(/.*/, prefix: 'bla-bla-bla')

      subject.prefix('bla-bla-bla') { match(/.*/) }
    end

    it 'adds nil prefix into options for all calls of a method in block' do
      expect(subject).to receive(:match).with(/.*/, prefix: nil)

      subject.prefix(nil) { match(/.*/) }
    end
  end

  describe '#use' do
    let(:middlewares) { double(:middlewares) }
    let(:router) { double(:router, middlewares: middlewares) }
    let(:args) { ['Middleware', 'arg1', 'arg2'] }

    it 'delegates to middleware builder of router' do
      expect(middlewares).to receive(:use).with(*args)
      subject.use(*args)
    end
  end

  describe '#command' do
    it 'constructs regexp and calls match method' do
      expect(subject).to receive(:match).with(/(?<command>command1|command2)/, controller: 'Controller')
      subject.command('command1', 'command2', controller: 'Controller')
    end

    it 'constructs regexp and calls match method' do
      expect(subject).to receive(:match).with(
        /(?<command>command1|command2)\s+(?<arg1>[A-Z]{2})\s+(?<arg2>[A-Z]{2})/,
        controller: 'Controller'
      )

      subject.command('command1', 'command2', arg1: /[A-Z]{2}/, arg2: /[A-Z]{2}/, controller: 'Controller')
    end

    it 'constructs regexp and calls match method' do
      expect(subject).to receive(:match).with(
        /(?<command>command1|command2)\s(?<arg1>[A-Z]{2})\stext/,
        controller: 'Controller', :delimiter=>/\s/
      )

      subject.command('command1', 'command2', arg1: /[A-Z]{2}/, arg2: 'text', delimiter: /\s/, controller: 'Controller')
    end
  end

  describe '#match' do
    let(:routes) { [] }
    let(:router) { double(:router, routes: routes) }

    it 'adds route' do
      subject.match(/.*/, direct: true, controller: 'Controller')
      expect(routes).to_not be_empty

      expect(routes[0].regexp).to eq(/.*/)
      expect(routes[0].options).to eq(direct: true)
      expect(routes[0].controller).to eq('Controller')
    end
  end
end
