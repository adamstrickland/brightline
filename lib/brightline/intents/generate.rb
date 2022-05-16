# frozen_string_literal: true

require "active_support/concern"
require "./lib/intents/intent"

module Intents
  module Generate
    extend ActiveSupport::Concern

    included do
      include ::Intents::Intent
    end

    def as_meta
      as_meta_without_operation.merge operation: :create
    end
  end
end
