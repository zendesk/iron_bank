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
  # When Zuora return InternalServerError we can not extract fields from the a message.
  # For this case we are doing binary search through the query fields and it could be
  # expensive due to repeatedly querying.
  fields      = IronBank::Schema.excluded_fields.sort.to_h

  File.write(destination, Psych.dump(fields))
end

# Helper function to set up an `IronBank::Client` instance
def setup_iron_bank
  require "dotenv/load"
  require "iron_bank"

  IronBank.configure do |config|
    config.client_id            = ENV.fetch("ZUORA_CLIENT_ID", nil)
    config.client_secret        = ENV.fetch("ZUORA_CLIENT_SECRET", nil)
    config.auth_type            = ENV.fetch("ZUORA_AUTH_TYPE", "token")
    config.domain               = ENV.fetch("ZUORA_DOMAIN", nil)
    config.excluded_fields_file = ENV.fetch("ZUORA_EXCLUDED_FIELDS_FILE", nil)
  end
end
