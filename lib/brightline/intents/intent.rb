# frozen_string_literal: true

require "active_support/concern"
require "./lib/messages/message"

module Intents
  module Intent
    extend ActiveSupport::Concern

    included do
      include ::Messages::Message
      alias_method :as_meta_with_type, :as_meta_without_operation
    end

    def as_meta_without_operation
      as_meta_without_type.merge type: :intent
    end
  end
end
