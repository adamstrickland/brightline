require "spec_helper"

RSpec.describe Models::Base, :mixin do
  let(:klass) do
    Class.new do
      attr_accessor :bar
    end
  end

  it { expect(klass).to respond_to :hydrate }

  describe ".hydrate" do
    subject { klass.hydrate(message) }

    context "when the message is a string" do
      let(:message) { "blurg" }
      it { is_expected.to be_falsy }
    end

    context "when the message is a hash" do
      context "without a :data key" do
        let(:message) { {} }
        it { is_expected.to be_falsy }
      end

      context "with a :data key" do
        let(:message) { { data: data } }

        context "and the :data key is a string" do
          let(:data) { "foo" }
          it { is_expected.to be_falsy }
        end

        context "and the :data key is a hash" do
          context "with keys not in the klass" do
            let(:data) { { foo: "foo" } }

            it { is_expected.to be_a klass }
            it "has nil attributes" do
              expect(subject.bar).to be_nil
            end
          end

          context "with key(s) in the klass" do
            let(:bar) { "bar" }
            let(:data) { { bar: bar } }

            it { is_expected.to be_a klass }

            it "has nil attributes" do
              expect(subject.bar).to eq bar
            end

            context "but all the keys are strings instead of symbols" do
              let(:message) do
                super().deep_stringify_keys
              end
              it { is_expected.to be_a klass }
            end
          end
        end
      end
    end
  end
end

