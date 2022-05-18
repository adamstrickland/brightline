# frozen_string_literal: true

require_relative "consumers/generic_consumer"

require_relative "consumers/kafka_consumer"
require_relative "consumers/sns_consumer"

require_relative "consumers/strategies"

module Brightline
  module Consumers
    IncompatibleConsumerError = Class.new(StandardError)
  end
end
