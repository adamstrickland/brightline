# frozen_string_literal: true

require "spec_helper"
require "./lib/utils/loggable"

RSpec.describe ::Utils::Loggable, :mixin, quiet: true do
  it { expect(klass).to respond_to :error }
  it { expect(klass).to respond_to :warn }
  it { expect(klass).to respond_to :info }
  it { expect(klass).to respond_to :debug }
  it { expect(klass).to respond_to :logger }

  it { expect(described_instance).to respond_to :error }
  it { expect(described_instance).to respond_to :warn }
  it { expect(described_instance).to respond_to :info }
  it { expect(described_instance).to respond_to :debug }
  it { expect(described_instance).to respond_to :logger }

  shared_examples_for "delegates calls to the logger" do
    let(:message) { "shucks!" }

    it "calls #error on the logger" do
      subject
      expect(logger).to have_received(:error).with(message)
    end
  end

  describe ".error" do
    subject { klass.error(message) }

    it_behaves_like "delegates calls to the logger"
  end

  describe "#error" do
    subject { described_instance.error(message) }

    it_behaves_like "delegates calls to the logger"
  end
end
