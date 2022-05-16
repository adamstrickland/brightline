# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require "active_support/core_ext/hash"

require "aws-sdk-core"
require "aws-sdk-dynamodb"

require_relative "../utils/loggable"

module Brightline
  module Models
    module Base
      extend ActiveSupport::Concern

      included do
        include Utils::Loggable
      end

      attr_reader :id

      def initialize
        @id = SecureRandom.uuid
      end

      def as_json
        { id: id }
      end

      def save!
        as_json.tap do |item|
          debug "Saving to #{table_name}: #{item.inspect} ..."
          table.put_item({ item: item }).tap do
            debug "... saved"
          end
        end
      end

      def save
        save!
        true
      rescue StandardError => e
        error e.message
        false
      end

      def namespaced_table_name
        @namespaced_table_name ||= class_name.underscore
      end

      DELIMITER = %r{/}.freeze

      def table_name
        @table_name ||= namespaced_table_name.split(DELIMITER).last.pluralize
      end

      def class_name
        @class_name ||= self.class.to_s
      end

      # def schema_name
      #   self.namespaced_table_name.split(DELIMITER)[0..-2]
      # end

      def table
        @table ||= Aws::DynamoDB::Table.new(table_name).tap(&:load)
      end

      def client
        @client ||= Aws::DynamoDB::Client.new
      end

      class_methods do
        def hydrate(message)
          debug "Hydrating to #{name}: #{message.inspect} ..."

          return nil unless message.respond_to?(:keys)

          symbolized_message = message.deep_symbolize_keys

          return nil unless symbolized_message.keys.include?(:data)

          data = symbolized_message[:data]

          return nil unless data.respond_to?(:keys)

          hydrate_from_hash(data)
        end

        def hydrate_from_hash(hash)
          new.tap do |inst|
            hash.compact.each_key do |key|
              setter = "#{key}=".to_sym

              inst.send(setter, hash[key]) if inst.respond_to?(setter)
            end
          end
        end
      end
    end
  end
end
