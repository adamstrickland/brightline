# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brightline::Consumers::KafkaConsumer, :mixin do
  describe ".call" do
    subject { modified_class.call(event: event, context: {}) }

    let(:handler) { ->(p) { p } }

    before do
      modified_class.send(:define_method, :call, handler)
    end

    context "when the event is an SNS event" do
      let(:event) do
        {
          "records" => {
            "topicname-0" => [
              {
                "topic" => "topicname",
                "value" => value,
              },
            ],
          },
        }
      end
      let(:payload) do
        {
          foo: "bar",
          "qux" => "quux",
        }
      end
      let(:raw_value) { payload.to_json }
      let(:value) { Base64.encode64(raw_value) }

      context "and the message is a raw string" do
        let(:raw_value) { "some string" }

        it { is_expected.to be_an Array }
        it { is_expected.to match_array [raw_value] }
      end

      context "and the message is JSON" do
        let(:raw_value) { JSON.dump(payload) }

        it { is_expected.to be_an Array }
        it { is_expected.to match_array [payload.deep_symbolize_keys] }
      end

      context "and when the underlying call raises an error" do
        let(:handler) { ->(_) { raise "ACK!" } }

        it { is_expected.to be_an Array }
        it { is_expected.to contain_exactly(kind_of(StandardError)) }
      end
    end
  end
end
