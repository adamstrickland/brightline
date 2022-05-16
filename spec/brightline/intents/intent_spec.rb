# frozen_string_literal: true

require "spec_helper"

RSpec.describe Intents::Intent, :mixin do
  describe "#as_meta_without_operation" do
    subject { described_instance.as_meta_without_operation }

    it { is_expected.to match hash_including(type: :intent) }
  end
end
