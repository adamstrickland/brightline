# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brightline::Consumers::Strategies::OnFailRollback, :mixin do
  let(:handler) { ->(p) { p } }

  before do
    modified_class.send(:define_method, :call, handler)
  end

  describe "when included in an SNS consumer", include: false do
    it "raises an error" do
      expect do
        include!
      end.to raise_error Brightline::Consumers::IncompatibleConsumerError
    end
  end

  context "when included in a Kafka consumer", include: false do
    before do
      include!(Brightline::Consumers::KafkaConsumer)
    end

    it "does not raise an error" do
      expect do
        include!
      end.not_to raise_error Brightline::Consumers::IncompatibleConsumerError
    end

    describe do
      before do
        include!
      end

      it "defines the .on_fail_rollback macro" do
        aggregate_failures do
          expect(modified_class).to respond_to :on_fail_rollback
          modified_class.method(:on_fail_rollback).tap do |m|
            expect(m.parameters).to include %i[keyreq with]
          end
        end
      end

      describe ".on_fail_rollback" do
        describe "when using a proc" do
          before do
            modified_class.class_eval do
              on_fail_rollback with: ->(_) { true }
            end
          end

          it "defines a :rollback_with method" do
            expect(described_instance).to respond_to :rollback_with
          end

          describe "#rollback_with" do
            subject { described_instance.rollback_with(:placeholder) }

            it { is_expected.to be_truthy }
          end
        end

        describe "when using a symbol" do
          before do
            modified_class.class_eval do
              def do_rollback!(_)
                true
              end
            end
          end

          context "that does not match a method name" do
            before do
              modified_class.class_eval do
                on_fail_rollback with: :non_matching_method_name
              end
            end

            it "defines a :rollback_with method" do
              expect(described_instance).to respond_to :rollback_with
            end

            describe "#rollback_with" do
              subject { described_instance.rollback_with(:placeholder) }

              it "raises an error when invoked" do
                expect do
                  subject
                end.to raise_error NoMethodError
              end
            end
          end

          context "that matches a method name" do
            before do
              modified_class.class_eval do
                on_fail_rollback with: :do_rollback!
              end
            end

            it "defines a :rollback_with method" do
              expect(described_instance).to respond_to :rollback_with
            end

            describe "#rollback_with" do
              subject { described_instance.rollback_with(:placeholder) }

              it { is_expected.to be_truthy }
            end
          end
        end
      end
    end

    describe ".call" do
      subject { described_instance.class.call(event: event, context: {}) }

      before do
        include!

        modified_class.class_eval do
          on_fail_rollback with: :do_rollback!

          def do_rollback!(_)
            true
          end
        end
      end

      let(:event) do
        {
          "records" => {
            "topicname-0" => [
              { "value" => Base64.encode64("meaningless") },
            ],
          },
        }
      end

      context "when the underlying call raises an error" do
        let(:handler) { ->(_) { raise "ACK!" } }

        it "raises a batch rollback error" do
          expect do
            subject
          end.to raise_error Brightline::Consumers::BatchRollbackError
        end
      end
    end
  end
end
