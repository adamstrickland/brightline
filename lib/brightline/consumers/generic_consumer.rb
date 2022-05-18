# frozen_string_literal: true

require "json"

require "brightline/handler"
require "brightline/utils/loggable"

module Brightline
  module Consumers
    module GenericConsumer
      extend ActiveSupport::Concern

      included do
        include Handler
        include Utils::Loggable
      end

      class_methods do
        def handle(event, context)
          debug "Consuming using #{self} ..."
          consume(event, context).tap do
            debug "... consumed"
          end
        end

        def consume(event, context)
          new.consume_event(event, context)
        end
      end

      def consume_event(event, context)
        consume_payloads(payloads_from_event(event, context))
      end

      def payloads_from_event(event, context)
        raise NotImplementedError
      end

      def message_to_payload(message)
        maybe = ->(obj) { obj.respond_to?(:deep_symbolize_keys) }

        return message.deep_symbolize_keys if maybe.call(message)

        parsed_message = try_parse_message(message)

        return parsed_message.deep_symbolize_keys if maybe.call(parsed_message)

        parsed_message
      end

      def try_parse_message(message)
        JSON.parse(message)
      rescue JSON::ParserError
        message
      end

      def consume_payloads(payloads)
        payloads.map do |payload|
          consume_payload(payload)
        end
      end

      def consume_payload(payload)
        consume_payload!(payload)
      rescue StandardError => e
        e
      end

      def consume_payload!(payload)
        debug "Handling #{payload.inspect} ..."
        call(payload).tap do
          debug "... handled"
        end
      rescue StandardError => e
        error e.message
        raise e
      end
    end
  end
end
