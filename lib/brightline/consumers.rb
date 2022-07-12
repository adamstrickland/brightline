# frozen_string_literal: true

require_relative "consumers/generic_consumer"

require_relative "consumers/kafka_consumer"
require_relative "consumers/sns_consumer"

require_relative "consumers/strategies"

module Brightline
  module Consumers
    ConsumerError = Class.new(StandardError)

    BatchFailureError = Class.new(ConsumerError)

    BatchRollbackError = Class.new(BatchFailureError) do
      def initialize(failures:, rollbacks:)
        super

        @failures = failures
        @rollbacks = rollbacks
      end

      attr_reader :failures, :rollbacks
    end

    IncompatibleConsumerError = Class.new(ConsumerError)
  end
end
