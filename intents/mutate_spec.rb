# frozen_string_literal: true

require "spec_helper"
require "./lib/intents/mutate"

RSpec.describe ::Intents::Mutate, :mixin do
  let(:klass) do
    Class.new do
      # mocking this method, b/c we're assuming the concrete Intent classes are
      # instances of `Struct`s, which use this method to enumerate the data
      # attributes of the struct.
      def members
        [:foo]
      end
    end
  end

  describe "#as_meta" do
    subject { described_instance.as_meta }

    it { is_expected.to be_a Hash }

    it { is_expected.to have_key :operation }
    it { expect(subject[:operation]).to eq :update }

    it { is_expected.to have_key :changeset }
    it { expect(subject[:changeset]).to be_a Hash }

    it { expect(subject[:changeset]).to have_key :foo }
    it { expect(subject[:changeset][:foo]).to be_an Array }
  end
end
