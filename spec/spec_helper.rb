# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "dotenv/load"
require "bundler/setup"
require "iron_bank"
require "factory_bot"
require "support/factory_bot"
require "pry-byebug"
require "shoulda/matchers"
require "logger"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Shoulda::Matchers::Independent
end

IronBank.configure do |config|
  config.logger = IronBank::Logger.new(level: ::Logger::FATAL)
end
