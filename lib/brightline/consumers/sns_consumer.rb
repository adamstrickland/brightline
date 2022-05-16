# frozen_string_literal: true

require "json"
require "active_support/concern"
require "./lib/utils/loggable"

module Consumers
  module SnsConsumer
    extend ActiveSupport::Concern

    included do
      include ::Utils::Loggable
    end

    RECORDS_KEY = "Records"
    MESSAGE_PATH = [
      SNS_KEY = "Sns",
      MESSAGE_KEY = "Message",
    ].freeze

    class_methods do
      def call(event:, **_opts)
        debug "Consuming using #{self} event #{event.inspect} ..."
        new.handle_event(event).tap do
          debug "... consumed"
        end
      end
    end

    def handle_event(event)
      handle_payloads(payloads_from_event(event))
    end

    def payloads_from_event(event)
      messages_from_event(event).map do |message|
        message_to_payload(message)
      end.compact
    end

    def message_to_payload(message)
      return message if message.respond_to? :keys

      try_parse_message(message)
    end

    def try_parse_message(message)
      JSON.parse(message)
    rescue JSON::ParserError
      message
    end

    def messages_from_event(event)
      (event[RECORDS_KEY] || []).map do |rec|
        rec.dig(*MESSAGE_PATH)
      end.compact
    end

    def handle_payloads(payloads)
      payloads.map do |payload|
        handle_payload(payload)
      end
    end

    def handle_payload(payload)
      handle_payload!(payload)
    rescue StandardError => e
      e
    end

    def handle_payload!(payload)
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
