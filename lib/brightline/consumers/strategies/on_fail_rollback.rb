# frozen_string_literal: true

# :markup: Markdown

module Brightline
  module Consumers
    module Strategies
      module OnFailRollback
        extend ActiveSupport::Concern

        included do
          raise IncompatibleConsumerError unless include? KafkaConsumer
        end

        class_methods do
          ##
          # Sets up the consumer to detect processing failures and
          # recover by rolling back with a method or proc, indicated
          # by the +with:+ parameter.  The proc or method should take
          # a single argument, which is an Array of tuples.  Each
          # tuple is `[payload, result, verdict]`.  The `payload` is
          # the original (parsed) payload.  `result` is the result of
          # calling the consumers `#call` method with `payload` as the
          # argument.  `verdict` is a `Boolean`: `true` indicating
          # that the call to `#call` succeeded, and `false` if it does
          # not.
          #
          # The method/proc supplied should be able to roll back
          # whatever operation(s) were invoked in `#call`.
          #
          # @param [Symbol, Proc] with: the proc or symbol to the
          # method.
          def on_fail_rollback(with:)
            rollback_method = :rollback_with

            define_method rollback_method do |payloads_results_verdicts|
              executor = case with
                         when Proc
                           with
                         when String, Symbol
                           method(with)
                         end

              raise ArgumentError unless executor.arity == 1

              executor.call(payloads_results_verdicts)
            rescue NameError
              raise NoMethodError
            end

            define_method :results do |payloads|
              consume_payloads_without_rollback(payloads)
            end

            define_method :payloads_with_results_and_verdicts do |payloads|
              results = results(payloads)

              verdicts = results.map do |r|
                next false if r.is_a?(StandardError)

                true
              end

              payloads.zip(results, verdicts)
            end

            define_method :consume_payloads_with_rollback do |payloads|
              p_w_r_a_v = payloads_with_results_and_verdicts(payloads)

              success_predicate = ->(prv) { prv[2] }

              return p_w_r_a_v if p_w_r_a_v.all?(&success_predicate)

              send(rollback_method, p_w_r_a_v)

              rollbacks = p_w_r_a_v.select(&success_predicate)
              failures = p_w_r_a_v - rollbacks

              r_and_fs = {
                failures: failures,
                rollbacks: rollbacks,
              }

              raise BatchRollbackError.new(**r_and_fs)

            rescue BatchFailureError => e
              error(e)
              raise e
            rescue StandardError => e
              error(e)
              raise BatchFailureError, e
            end

            alias_method :consume_payloads_without_rollback, :consume_payloads
            alias_method :consume_payloads, :consume_payloads_with_rollback
          end
        end
      end
    end
  end
end
