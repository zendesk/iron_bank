# frozen_string_literal: true

require 'reek/rake/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'private_gem/tasks'
require 'bump/tasks'

Reek::Rake::Task.new do |reek|
  reek.fail_on_error = true
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |rspec|
  rspec.verbose = false
end

task test: :spec

task default: %i[rubocop reek spec]

desc 'Delete the VCR cassettes folder'
task :clean do
  sh 'rm -rf spec/vcr'
end

desc 'Export the Zuora Schema using the Describe API'
task :export_schema do
  require 'dotenv/load'
  require 'iron_bank'

  # Set up the client
  IronBank.client = IronBank::Client.new(
    domain:        ENV['ZUORA_DOMAIN'],
    client_id:     ENV['ZUORA_CLIENT_ID'],
    client_secret: ENV['ZUORA_CLIENT_SECRET'],
    auth_type:     ENV['ZUORA_AUTH_TYPE']
  )

  IronBank::Schema.export
end
