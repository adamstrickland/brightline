# frozen_string_literal: true

require "active_support/concern"

module QuietSupport
  extend ActiveSupport::Concern

  included do
    let(:logger) do
      double error: true,
             warn: true,
             info: true,
             debug: true
    end

    before do
      allow(Logger).to receive(:new).with(any_args).and_return(logger)
    end

    after do
      "@logger".tap do |varname|
        if described_class.instance_variables.include?(varname.to_sym)
          described_class.instance_variable_set(varname,
                                                nil)
        end
      end
    end
  end
end
