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

    before do |ex|
      include! if include_mixin?(ex)
    end
  end

  def include!(module_to_include=nil)
    module_to_include ||= mixin
    modified_class.send(:include, module_to_include)
  end

  def include_mixin?(example)
    return true unless example.metadata.keys.include?(:include)

    example.metadata[:include]
  end
end
