RSpec.describe Walle::Controller do
  let(:channel) { 'U2EU6KZDW' }
  let(:client) { double(:client) }
  let(:data) { Hashie::Mash.new(channel: channel) }
  let(:env) { Walle::Robot::Environment.new(:message, client, data) }

  subject { described_class.new(env) }

  before { described_class.send(:public, :typing, :message) }

  describe '#typing' do
    it 'delegates to client with current channel' do
      expect(client).to receive(:typing).with(channel: channel)
      subject.typing
    end

    it 'delegates to client' do
      expect(client).to receive(:typing).with(channel: 'WDZK6UE2U')
      subject.typing(channel: 'WDZK6UE2U')
    end
  end

  describe '#message' do
    it 'delegates to client with current channel' do
      expect(client).to receive(:message).with(channel: channel, text: 'Text')
      subject.message(text: 'Text')
    end

    it 'delegates to client' do
      expect(client).to receive(:message).with(channel: 'WDZK6UE2U', text: 'Text')
      subject.message(channel: 'WDZK6UE2U', text: 'Text')
    end
  end
end
