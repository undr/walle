RSpec.describe Walle::Robot::Definitions do
  subject { described_class.new }

  described_class::EVENTS.each do |event|
    it_should_behave_like :definitions_event, event
  end

  describe '#use' do
    let(:args) { ['Middleware', 'arg1', 'arg2'] }

    it 'delegate to middleware builder' do
      expect_any_instance_of(Walle::Middlewares::Builder).to receive(:use).with(*args)
      subject.use(*args)
    end
  end

  describe '#routes' do
    let(:env) { double(:env) }

    before { subject.routes {} }

    it 'adds message handler which calls router during request time' do
      expect(subject).to have(1).handlers(:message)
      expect_any_instance_of(Walle::Robot::Router).to receive(:call).with(env)

      subject.handlers(:message)[0].call(env)
    end
  end

  describe '#apply_to' do
    let(:client) { Slack::RealTime::MockClient.new }
    let(:handlers) { described_class::EVENTS.reduce({}) { |result, event| result.merge(event => -> (_) {}) } }

    before do
      handlers.each { |event, handler| subject.send(event, &handler) }

      subject.apply_to(client)
    end

    it 'applies all definitions to given client' do
      handlers.each do |event, handler|
        expect(client).to have(1).handler(event)
      end
    end
  end

  describe '#handlers' do
    let(:handler1) { -> (_) {} }
    let(:handler2) { -> (_) {} }

    before do
      subject.hello(&handler1)
      subject.message(&handler2)
    end

    specify { expect(subject.handlers).to include(handler1, handler2) }
    specify { expect(subject.handlers(:hello)).to include(handler1) }
    specify { expect(subject.handlers(:message)).to include(handler2) }
  end
end
