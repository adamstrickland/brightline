# frozen_string_literal: true

require "spec_helper"

RSpec.describe Intents::Generate, :mixin do
  describe "#as_meta" do
    subject { described_instance.as_meta }

    it { is_expected.to be_a Hash }

    it { is_expected.to have_key :operation }
    it { expect(subject[:operation]).to eq :create }
  end
end
