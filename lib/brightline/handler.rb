require "datadog/lambda"

module Brightline
  module Handler
    extend ActiveSupport::Concern

    included do
      include Utils::Loggable
    end

    class_methods do
      def call(event:, context:)
        Datadog::Lambda.wrap(event, context) do
          debug "Handling event #{event.inspect} ..."
          handle(event, context).tap do
            debug "... handled"
          end
        end
      end
    end
  end
end
