# frozen_string_literal: true

module Brightline
  module Consumers
    module Strategies
      module OnFailRollback
        extend ActiveSupport::Concern

        included do
          raise IncompatibleConsumerError unless self.include? KafkaConsumer
        end

        def consume_payload(payload)
          consume_payload!(payload)
        end
      end
    end
  end
end
