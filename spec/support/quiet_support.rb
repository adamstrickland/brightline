# frozen_string_literal: true

require "active_support/concern"

module QuietSupport
  extend ActiveSupport::Concern

  included do
    around do |ex|
      o = $stdout
      e = $stderr
      $stderr = StringIO.new
      $stdout = StringIO.new

      ex.run

      $stderr = e
      $stdout = o
    end
  end

  class StreamMatcher
    def initialize(expected)
      @expected = if expected.is_a? String
                    Regexp.new(Regexp.quote(expected))
                  else
                    expected
                  end
    end

    def matches?(actual)
      return false unless actual.is_a?(Proc)

      return false unless @expected.is_a?(Regexp)

      actual.call

      $stdout.string =~ @expected
    end

    def supports_block_expectations?
      true
    end
  end

  def send_to_stdout(expected)
    StreamMatcher.new(expected)
  end
end
