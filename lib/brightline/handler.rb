require "datadog/lambda"

module Brightline
  module Handler
    extend ActiveSupport::Concern

    class_methods do
      def call(event:, context:)
        Datadog::Lambda.wrap(event, context) do
          debug "Handling event #{event.inspect} ..."
          new.call(event: event, context: context).tap do
            debug "... handled"
          end
        end
      end
    end
  end
end
