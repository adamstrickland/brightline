# frozen_string_literal: true

require "active_support/concern"

module MixinSupport
  extend ActiveSupport::Concern

  included do
    let(:klass) do
      Class.new do
      end
    end
    let(:mixin) { described_class }
    let(:klass_name) { mixin.to_s }
    let(:modified_class) { klass }
    let(:described_instance) { modified_class.new }

    before do
      # Object.const_set(klass_name, klass)
      klass.send(:include, mixin)
    end
  end
end
