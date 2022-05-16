# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/hash"
require "aws-sdk-core"
require "seahorse"
require "aws-sdk-kafka"
require "aws-sdk-secretsmanager"
require "./lib/utils/loggable"
require "json"
require "waterdrop"

module Publishers
  class KafkaPublisher
    include ::Utils::Loggable

    INIT_KW_MISSING_ERR = "Either :broker_url or :cluster_arn must be provided."

    def initialize(topic:, **options)
      @topic = topic

      @cluster_arn = options[:cluster_arn]
      @broker_url = options[:broker_url]

      raise ArgumentError, INIT_KW_MISSING_ERR if @cluster_arn.nil? && @broker_url.nil?

      @secrets_arn = options[:secrets_arn]
    end

    attr_reader :topic,
                :cluster_arn,
                :secrets_arn,
                :broker_url

    def call(intent)
      debug "Producing #{intent.inspect}..."
      producer.produce_async(topic: topic,
                             payload: intent.to_json).tap do
                               debug "...Done"
                             end
    end

    def bootstrap_servers
      @bootstrap_servers ||= kafka_url
    end

    def kafka_options
      base_options = {
        'bootstrap.servers': bootstrap_servers,
      }

      return base_options unless sasl?

      u, p = secrets.then { |h| [h[:username], h[:password]] }

      base_options.merge({
                           'sasl.mechanism': "SCRAM-SHA-512",
                           'sasl.username': u,
                           'sasl.password': p,
                         })
    end

    private

    def msk
      @msk ||= Aws::Kafka::Client.new
    end

    def sm
      @sm ||= Aws::SecretsManager::Client.new
    end

    def secrets
      debug "Retrieving secrets for #{secrets_arn} ..."
      ss = sm.get_secret_value(secret_id: secrets_arn)
             .secret_string.tap do
               debug "... Received secrets"
             end
      JSON.parse(ss).deep_symbolize_keys
    rescue StandardError => e
      debug "Error retrieving secrets: #{e.message}"
      raise e
    end

    def kafka_url
      if broker_url
        debug "Using provided broker URL #{broker_url}"
        broker_url
      else
        debug "Deriving broker URL from ARN #{cluster_arn}"
        derived_broker_url
      end
    end

    def derived_broker_url
      debug "Retrieving bootstrap brokers..."
      config = msk.get_bootstrap_brokers(cluster_arn: cluster_arn).tap do |info|
        debug "... Received bootstrap brokers: #{info.inspect}"
      end

      return config.bootstrap_broker_string_sasl_scram if sasl?

      config.bootstrap_broker_string
    rescue StandardError => e
      debug "Error retrieving bootstrap brokers: #{e.message}"
      raise e
    end

    def producer
      @producer ||= WaterDrop::Producer.new do |config|
        config.deliver = true
        config.kafka = kafka_options
      end
    end

    def sasl?
      secrets_arn.present?
    end

    def ready?
      return false if kafka_url.nil?
      return false if producer.nil?
    end
  end
end
