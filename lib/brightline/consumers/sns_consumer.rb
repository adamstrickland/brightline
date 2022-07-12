# frozen_string_literal: true

require_relative "generic_consumer"

module Brightline
  module Consumers
    module SnsConsumer
      extend ActiveSupport::Concern

      RECORDS_KEY = "Records"
      MESSAGE_PATH = [
        SNS_KEY = "Sns",
        MESSAGE_KEY = "Message",
      ].freeze

      included do
        include GenericConsumer
        include SnsConsumerImpl
      end

      module SnsConsumerImpl
        extend ActiveSupport::Concern

        def payloads_from_event(event, context)
          (event[RECORDS_KEY] || []).map do |rec|
            rec.dig(*MESSAGE_PATH)
          end.compact.map do |message|
            message_to_payload(message)
          end.compact
        end

        # def messages_from_event(event)
        #   (event[RECORDS_KEY] || []).map do |rec|
        #     rec.dig(*MESSAGE_PATH)
        #   end.compact
        # end
      end
    end
  end
end
