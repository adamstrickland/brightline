# frozen_string_literal: true

require "aws-sdk-core"
require "seahorse"
require "aws-sdk-sns"

module Publishers
  class SnsPublisher
    def initialize(topic:)
      @topic = topic
    end

    attr_reader :topic

    def call(intent)
      message = {
        topic_arn: topic,
        message: intent.to_json,
      }

      sns.publish(message)
    end

    def sns
      Aws::SNS::Client.new
    end
  end
end
