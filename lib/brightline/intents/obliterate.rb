# frozen_string_literal: true

require "active_support/concern"
require_relative "./intent"

module Brightline
  module Intents
    module Obliterate
      extend ActiveSupport::Concern

      included do
        include Intents::Intent
      end

      def as_meta
        as_meta_without_operation.merge operation: :delete
      end
    end
  end
end
