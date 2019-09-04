# frozen_string_literal: true

require "reek/rake/task"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bump/tasks"

Reek::Rake::Task.new do |reek|
  reek.fail_on_error = true
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |rspec|
  rspec.verbose = false
end

task test: :spec

task default: %i[rubocop reek spec]

desc "Export the Zuora Schema using the Describe API"
task :export_schema do
  setup_iron_bank
  IronBank::Schema.export
end

desc "Query Zuora for fields that we should not use in a query"
task :excluded_fields, [:filename] do |_t, args|
  require "psych"
  setup_iron_bank

  destination = args[:filename] || IronBank.configuration.excluded_fields_file
  fields      = IronBank::Schema.excluded_fields

  File.open(destination, "w") { |file| file.write(Psych.dump(fields)) }
end

# Helper function to set up an `IronBank::Client` instance
def setup_iron_bank
  require "dotenv/load"
  require "iron_bank"

  IronBank.configure do |config|
    config.client_id            = ENV["ZUORA_CLIENT_ID"]
    config.client_secret        = ENV["ZUORA_CLIENT_SECRET"]
    config.auth_type            = ENV.fetch("ZUORA_AUTH_TYPE", "token")
    config.domain               = ENV["ZUORA_DOMAIN"]
    config.excluded_fields_file = ENV["ZUORA_EXCLUDED_FIELDS_FILE"]
  end
end
