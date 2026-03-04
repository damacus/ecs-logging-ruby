# frozen_string_literal: true

require_relative 'lib/ecs_logging/version'

Gem::Specification.new do |spec|
  spec.name          = "ecs-logging"
  spec.version       = EcsLogging::VERSION
  spec.authors       = ["Dan Webb"]
  spec.email         = ["dan.webb@damacus.io"]

  spec.summary       = %q{A Ruby logging library for the Elastic Common Schema (ECS).}
  spec.description   = %q{Write logs in a structured JSON format that complies with the Elastic Common Schema (ECS).}
  spec.homepage      = "https://github.com/damacus/ecs-logging-ruby"
  spec.license       = 'Apache-2.0'

  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/blob/main/CHANGELOG.md'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]
end
