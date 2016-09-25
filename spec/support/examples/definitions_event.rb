shared_examples_for :definitions_event do |event_name|
  let(:event) { event_name }
  let(:handler) { -> (*) {} }

  subject { described_class.new }

  before { subject.send(event, &handler) }

  it { expect(subject).to have(1).handler(event) }
  it { expect(subject).to have_handlers.include(handler) }
end
