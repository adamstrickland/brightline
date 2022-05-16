# frozen_string_literal: true

require "active_support/concern"
require "./lib/messages/message"

module Messages
  module Fact
    extend ActiveSupport::Concern

    included do
      include ::Messages::Message
    end

    def as_meta_without_operation
      as_meta_without_type.merge type: :fact
    end
    alias as_meta as_meta_without_operation
  end
end
