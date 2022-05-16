# frozen_string_literal: true

require "active_support/concern"

module MixinSupport
  extend ActiveSupport::Concern

  included do
    let(:klass) do
      Class.new do
      end
    end
    let(:klass_name) { described_class.to_s }
    let(:described_instance) { klass.new }

    before do
      # Object.const_set(klass_name, klass)
      klass.send(:include, described_class)
    end
  end
end
