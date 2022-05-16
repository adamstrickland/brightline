# frozen_string_literal: true

require "logger"
require "active_support/concern"
require "forwardable"

module Utils
  module Loggable
    extend ActiveSupport::Concern

    LOGGING_METHODS = %i[error warn info debug].freeze

    included do
      class << self
        extend Forwardable
        delegate LOGGING_METHODS => :logger
      end

      extend Forwardable
      delegate LOGGING_METHODS => :logger
    end

    class_methods do
      def logger
        @logger ||= Logger.new($stdout)
      end
    end

    def logger
      self.class.logger
    end
  end
end
