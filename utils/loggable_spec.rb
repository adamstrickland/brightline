require "spec_helper"
require "./lib/utils/loggable"

RSpec.describe ::Utils::Loggable, :mixin, quiet: true do
  it { expect(described_instance).to respond_to :error }
  it { expect(described_instance).to respond_to :warn }
  it { expect(described_instance).to respond_to :info }
  it { expect(described_instance).to respond_to :debug }
  it { expect(described_instance).to respond_to :logger }

  describe "#error" do
    subject { described_instance.error(message) }

    let(:message) { "shucks!" }

    it "calls #error on the logger" do
      subject
      expect(logger).to have_received(:error).with(message)
    end
  end
end
