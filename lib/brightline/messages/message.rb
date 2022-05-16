# frozen_string_literal: true

require "active_support/concern"
require "active_support/inflector"

module Brightline
  module Messages
    module Message
      extend ActiveSupport::Concern

      def as_json
        {
          meta: as_meta,
          data: as_data,
        }
      end

      def as_data
        to_h
      end

      def as_meta_without_type
        {
          model: self.class.to_s.underscore.dasherize,
          ts: Time.now.utc,
        }
      end

      def to_json(*_args)
        JSON.dump(as_json)
      end
    end
  end
end
