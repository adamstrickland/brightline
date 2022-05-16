require "sentry-lambda"

module Brightline
  module Handler
    extend ActiveSupport::Concern

    included do
      include Utils::Loggable
    end

    class_methods do
      def call(event:, context:)
        Sentry::Lambda.wrap_handler(event: event,
                                    context: context,
                                    capture_timeout_warning: true) do
          debug "Handling event #{event.inspect} ..."
          handle(event, context).tap do
            debug "... handled"
          end
        end
      end
    end
  end
end
