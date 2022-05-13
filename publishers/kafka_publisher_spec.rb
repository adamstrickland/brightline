# frozen_string_literal: true

require "spec_helper"

RSpec.describe Publishers::KafkaPublisher do
  let(:described_instance) { described_class.new(topic: "foo", **options) }
  let(:options) { {} }

  describe "#bootstrap_servers" do
    subject { described_instance.bootstrap_servers }

    context "when initialized with a :broker_url" do
      let(:broker_url) { Faker::Internet.url }
      let(:options) do
        super().merge({
                        broker_url: broker_url,
                      })
      end

      it { is_expected.to eq broker_url }
    end

    context "when initialized with a :cluster_arn" do
      let(:sasl_broker_url) { Faker::Internet.url }
      let(:plain_broker_url) { Faker::Internet.url }

      let(:cluster_arn) { "cluster_arn" }
      let(:options) do
        super().merge({
                        cluster_arn: cluster_arn,
                      })
      end
      let(:client) { double }
      let(:broker_config) do
        double(bootstrap_broker_string_sasl_scram: sasl_broker_url,
               bootstrap_broker_string: plain_broker_url)
      end

      before do
        allow(Aws::Kafka::Client).to receive(:new).and_return(client)
        allow(client).to receive(:get_bootstrap_brokers).with(cluster_arn: cluster_arn).and_return(broker_config)
      end

      context "when initialized with :secrets_arn" do
        let(:options) { super().merge(secrets_arn: "secrets_arn") }

        it { is_expected.to eq sasl_broker_url }
      end

      context "when initialized without :secrets_arn" do
        before do
          expect(options).not_to have_key :secrets_arn
        end

        it { is_expected.to eq plain_broker_url }
      end
    end

    context "when initialized with neither" do
      it "raises an error" do
        expect do
          subject
        end.to raise_error ArgumentError
      end
    end
  end
end
