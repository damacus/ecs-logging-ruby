# frozen_string_literal: true

require "bundler/setup"

Bundler.require :default, :test

require "ecs_logging"
require 'yarjuf'

$:<<(File.expand_path(__dir__ + '/..'))

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
