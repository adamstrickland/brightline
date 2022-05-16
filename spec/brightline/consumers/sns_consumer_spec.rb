# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brightline::Consumers::SnsConsumer, :mixin do
  describe ".call" do
    subject { klass.call(event: event, context: ctx) }

    let(:ctx) do
      double invoked_function_arn: "arn",
             function_name: "fn",
             memory_limit_in_mb: 0,
             aws_request_id: "1"
    end
    let(:handler) { ->(_) { true } }

    before do
      klass.send(:define_method, :call, handler)
    end

    context "when the event is an SNS event" do
      let(:event) do
        {
          "Records" => [
            {
              "Sns" => {
                "Message" => message,
              },
            },
          ],
        }
      end
      let(:payload) do
        {
          foo: "bar",
          "qux" => "quux",
        }
      end
      let(:message) { payload }

      context "and the message is a raw string" do
        let(:message) { "some string" }

        it { is_expected.to be_an Array }
        it { is_expected.to match_array [true] }
      end

      context "and the message is JSON" do
        context "pre-parsed into an object" do
          it { is_expected.to be_an Array }
          it { is_expected.to match_array [true] }
        end

        context "still unparsed string" do
          let(:message) { JSON.dump(payload) }

          it { is_expected.to be_an Array }
          it { is_expected.to match_array [true] }
        end
      end

      context "and when the underlying call raises an error" do
        let(:handler) { ->(_) { raise "ACK!" } }

        it { is_expected.to be_an Array }
        it { is_expected.to contain_exactly(kind_of(StandardError)) }
      end
    end
  end
end
