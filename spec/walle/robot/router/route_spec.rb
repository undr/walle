RSpec.describe Walle::Robot::Router::Route do
  let(:client) { { self: { id: 'U2EU6KZDW' } } }
  let(:data) { { text: text } }
  let(:env) { Hashie::Mash.new(client: client, data: data)}
  let(:text) { '' }

  describe Walle::Robot::Router::Route::Direct do
    subject { described_class.new(env, regexp, options).mutate }

    describe '#mutate' do
      let(:regexp) { /\d{2,4}(some|regexp).*/ }

      context 'for direct routes' do
        let(:options) { { direct: true } }

        it { is_expected.to eq(/<@U2EU6KZDW>\s+\d{2,4}(some|regexp).*/) }

        context 'when regexp is nil' do
          let(:regexp) { nil }

          it { is_expected.to eq(/<@U2EU6KZDW>\s+.*/) }
        end
      end

      context 'for the rest routes' do
        let(:options) { { } }

        it { is_expected.to eq(regexp) }

        context 'when regexp is nil' do
          let(:regexp) { nil }

          it { is_expected.to eq(regexp) }
        end
      end
    end
  end

  describe Walle::Robot::Router::Route::Prefix do
    subject { described_class.new(env, regexp, options).mutate }

    describe '#mutate' do
      let(:regexp) { /\d{2,4}(some|regexp).*/ }

      context 'without options' do
        let(:options) { { } }

        it { is_expected.to eq(/.*\d{2,4}(some|regexp).*/) }

        context 'when regexp is nil' do
          let(:regexp) { nil }

          it { is_expected.to eq(/.*/) }
        end
      end

      context 'with prefix' do
        let(:options) { { prefix: 'hi ' } }

        it { is_expected.to eq(/hi \d{2,4}(some|regexp).*/) }

        context 'when regexp is nil' do
          let(:regexp) { nil }

          it { is_expected.to eq(/hi /) }
        end
      end

      context 'when prefix equals false' do
        let(:options) { { prefix: false } }

        it { is_expected.to eq(regexp) }

        context 'when regexp is nil' do
          let(:regexp) { nil }

          it { is_expected.to eq(regexp) }
        end
      end
    end
  end

  describe '.match?' do
    subject { described_class.new(options).match?(env) }

    let(:regexp) { /(command)\s+.*/ }

    context 'for direct routes' do
      let(:text) { 'command me' }
      let(:options) { { regexp: regexp, direct: true, controller: '' } }

      it { is_expected.to be_falsy }

      context 'when text with robot name' do
        let(:text) { '<@U2EU6KZDW> command me' }

        it { is_expected.to be_truthy }
      end

      context 'when regexp is nil' do
        let(:regexp) { nil }

        it { is_expected.to be_falsy }

        context 'and text with robot name' do
          let(:text) { '<@U2EU6KZDW> command me' }

          it { is_expected.to be_truthy }
        end
      end
    end

    context 'for the rest routes' do
      let(:text) { 'command me' }
      let(:options) { { regexp: regexp, direct: false, controller: '' } }

      it { is_expected.to be_truthy }

      context 'when text with robot name' do
        let(:text) { '<@U2EU6KZDW> command me' }

        it { is_expected.to be_truthy }
      end

      context 'when regexp is nil' do
        let(:regexp) { nil }

        it { is_expected.to be_truthy }

        context 'and text with robot name' do
          let(:text) { '<@U2EU6KZDW> command me' }

          it { is_expected.to be_truthy }
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.new(options) }

    let(:controller) { double(:controller) }
    let(:options) { { regexp: regexp, controller: controller } }
    let(:regexp) { /(?<command>command)\s+.*/ }
    let(:text) { 'command me' }

    it 'calls controller with env contains matches' do
      expect(controller).to receive(:call) do |env|
        expect(env.matches[:command]).to eq('command')
      end

      subject.call(env)
    end

    context 'when regexp is nil' do
      let(:regexp) { nil }

      it 'calls controller with env' do
        expect(controller).to receive(:call).with(env)
        subject.call(env)
      end
    end
  end
end
