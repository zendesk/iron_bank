# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iron_bank/version"

Gem::Specification.new do |spec|
  spec.name     = "iron_bank"
  spec.version  = IronBank::VERSION
  spec.summary  = "An opinionated Ruby interface to the Zuora API."
  spec.homepage = "https://github.com/zendesk/iron_bank"
  spec.license  = "Apache-2.0"
  spec.authors  = ["Mickael Pham", "Cheng Cui", "Ryan Ringler", "Mustafa Turan"]

  spec.email = [
    "mickael@zendesk.com",
    "ccui@zendesk.com",
    "rringler@zendesk.com",
    "mturan@zendesk.com"
  ]

  spec.required_ruby_version = ">= 2.5"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday",            "~> 1"
  spec.add_dependency "faraday_middleware", "~> 1"
  spec.add_dependency "nokogiri",           "~> 1"
  spec.metadata["rubygems_mfa_required"] = "true"
end
