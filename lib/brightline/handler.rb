module Brightline
  module Handler
    extend ActiveSupport::Concern

    class_methods do
      def wrap(event:, context:, &block)
        debug "Handling event #{event.inspect} ..."
        if block_given?
          block.call
        end.tap do
          debug "... handled"
        end
      end
    end
  end
end
