# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brightline::Consumers::GenericConsumer, :mixin do
  describe ".handle" do
    subject { modified_class.handle(event, ctx) }

    let(:event) { {} }
    let(:ctx) { {} }

    describe "when the modified class does not have a .consume method" do
      it { expect { subject }.to raise_error NotImplementedError }
    end

    describe "when the modified class does have a .consume method" do
      before do
        modified_class.send(:define_singleton_method, :consume, handler)
      end

      let(:handler) { ->(_e, _c) { true } }

      it { is_expected.to be_truthy }
    end
  end
end
