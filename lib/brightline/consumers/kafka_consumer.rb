# frozen_string_literal: true

require_relative "generic_consumer"

module Brightline
  module Consumers
    module KafkaConsumer
      extend ActiveSupport::Concern

      included do
        include GenericConsumer
        include KafkaConsumerImpl
      end

      module KafkaConsumerImpl
        extend ActiveSupport::Concern

        def payloads_from_event(event, context)
          (event["records"] || []).flat_map do |_partition, records|
            records.map do |record|
              decode_value(record["value"])
            end
          end.compact.map do |message|
            message_to_payload(message)
          end.compact
        end

        def decode_value(encoded_value)
          Base64.decode64(encoded_value)
        end

        # def parse_value(decoded_value)
        #   try_parse_message(decoded_value).then do |pv|
        #     return pv.deep_symbolize_keys if pv.respond_to?(:deep_symbolize_keys)
        #     pv
        #   end
        # end
      end
    end
  end
end
