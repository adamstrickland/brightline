# frozen_string_literal: true

require "active_support/concern"
require_relative "./intent"

module Brightline
  module Intents
    module Mutate
      extend ActiveSupport::Concern

      included do
        include Intents::Intent
      end

      def as_meta
        as_meta_without_operation.merge operation: :update, changeset: changeset
      end

      def changeset
        members.to_h do |attr|
          [attr, []]
        end
      end
    end
  end
end
