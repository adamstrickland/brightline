# frozen_string_literal: true

require "faker"
require "pry"

require "brightline"

%w[
  support/**/*.rb
].each do |glob|
  Dir[File.join(__dir__, glob)].sort.each(&method(:require))
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.define_derived_metadata do |m|
    m[:quiet] = true unless (m.keys.include?(:quiet) && !m[:quiet]) || m[:loud]
  end
  config.include FixtureSupport
  config.include MixinSupport, :mixin
  config.include QuietSupport, quiet: true
end
