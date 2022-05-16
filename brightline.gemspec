# frozen_string_literal: true

require_relative "lib/brightline/version"

Gem::Specification.new do |spec|
  spec.name = "brightline"
  spec.version = Brightline::VERSION
  spec.authors = ["Adam Strickland"]
  spec.email = ["adam.strickland@hopin.to"]

  spec.summary = "Serverless tooling"
  spec.description = spec.summary
  spec.homepage = "https://github.com/hopin.com/product/brightline"
  spec.license = "MIT"
  # spec.required_ruby_version = ">= 2.7"

  spec.metadata["allowed_push_host"] = "https://hopinto.jfrog.io"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_dependency "activesupport", "~> 7.0.2"
  spec.add_dependency "aws-sdk-dynamodb"
  spec.add_dependency "aws-sdk-kafka"
  spec.add_dependency "aws-sdk-secretsmanager"
  spec.add_dependency "aws-sdk-sns"
  spec.add_dependency "waterdrop"

  spec.add_development_dependency "faker"
  spec.add_development_dependency "rspec"
end
