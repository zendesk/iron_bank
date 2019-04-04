# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iron_bank/version'

Gem::Specification.new do |spec|
  spec.name     = 'iron_bank'
  spec.version  = IronBank::VERSION
  spec.summary  = 'An opinionated Ruby interface to the Zuora API.'
  spec.homepage = 'https://github.com/zendesk/iron_bank'
  spec.license  = 'Apache-2.0'
  spec.authors  = ['Mickael Pham', 'Cheng Cui', 'Ryan Ringler', 'Mustafa Turan']

  spec.email = [
    'mickael@zendesk.com',
    'ccui@zendesk.com',
    'rringler@zendesk.com',
    'mturan@zendesk.com'
  ]

  spec.required_ruby_version = '>= 2.3'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bump',                '~> 0.5'
  spec.add_development_dependency 'bundler',             '~> 2.0'
  spec.add_development_dependency 'dotenv',              '~> 2.2'
  spec.add_development_dependency 'factory_bot',         '~> 5.0'
  spec.add_development_dependency 'pry-byebug',          '~> 3.4'
  spec.add_development_dependency 'rake',                '~> 12.0'
  spec.add_development_dependency 'reek',                '~> 5.0'
  spec.add_development_dependency 'rspec',               '~> 3.0'
  spec.add_development_dependency 'rubocop',             '~> 0.67'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'shoulda-matchers',    '~> 4.0'
  spec.add_development_dependency 'simplecov',           '~> 0.15'
  spec.add_development_dependency 'timecop',             '~> 0.9.0'
  spec.add_development_dependency 'vcr',                 '~> 4.0'
  spec.add_development_dependency 'webmock',             '~> 3.0'

  spec.add_runtime_dependency 'ddtrace',            '~> 0'
  spec.add_runtime_dependency 'faraday',            '~> 0'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0'
  spec.add_runtime_dependency 'nokogiri',           '~> 1'
end
