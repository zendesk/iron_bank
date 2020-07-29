# frozen_string_literal: true

# External librairies
require "csv"
require "faraday"
require "faraday_middleware"
require "fileutils"
require "json"
require "nokogiri"

# An opinionated Ruby interface to the Zuora REST API
module IronBank
  class << self
    # Holds an instance of IronBank::Client which becomes the default for many
    # query and other actions requiring a connection to Zuora.
    attr_accessor :client

    # Configurable options such as schema directory.
    attr_accessor :configuration

    attr_accessor :configurations, :clients
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)

    return unless configuration.credentials?

    self.client ||= IronBank::Client.new(**configuration.credentials)
  end

  # def self.configure_instance(&block)
  #   return unless block_given?

  #   IronBank::Instance.new(&block)
  # end

  def self.configure_instance(instance_name = nil)
    unless instance_name
      puts 'Instance name is required'
      return
    end

    self.configurations ||= {}
    self.configurations[instance_name] = Configuration.new
    config = self.configurations[instance_name]
    yield(config)
    return unless config.credentials?

    self.clients ||= {}
    self.clients[instance_name] = IronBank::Client.new(**config.credentials)
  end

  def self.with_instance(instance_name)
    unless self.configurations && self.configurations[instance_name]
      puts "Instance #{instance_name} is not setup"
      return
    end

    backup_configuration = self.configuration
    backup_client = self.client

    self.configuration = self.configurations[instance_name]
    self.client = self.clients[instance_name]

    yield

    self.configuration = backup_configuration
    self.client = backup_client
  end

  def self.logger
    self.configuration.logger
  end

  # Zuora actions, e.g., subscribe, amend, etc.
  module Actions; end

  # Metadata describe
  module Describe; end

  # Zuora resources
  module Resources; end

  # Zuora operations, e.g., billing-preview
  module Operations; end
end

# Utilities
require "iron_bank/logger"
require "iron_bank/cacheable"
require "iron_bank/configuration"
require "iron_bank/endpoint"
require "iron_bank/local_records"
require "iron_bank/local"
require "iron_bank/utils"
require "iron_bank/version"
require "iron_bank/csv"
require "iron_bank/error"
require "iron_bank/faraday_middleware/response/raise_error"
require "iron_bank/faraday_middleware/response/renew_auth"

# Use default configuration
IronBank.configure {}

# Actions
require "iron_bank/action"
require "iron_bank/actions/amend"
require "iron_bank/actions/create"
require "iron_bank/actions/delete"
require "iron_bank/actions/execute"
require "iron_bank/actions/generate"
require "iron_bank/actions/subscribe"
require "iron_bank/actions/update"
require "iron_bank/actions/query"
require "iron_bank/actions/query_more"

# Client and schema (describe)
require "iron_bank/authentication"
require "iron_bank/authentications/cookie"
require "iron_bank/authentications/token"
require "iron_bank/client"
require "iron_bank/describe/field"
require "iron_bank/describe/excluded_fields"
require "iron_bank/describe/object"
require "iron_bank/describe/related"
require "iron_bank/describe/tenant"
require "iron_bank/object"
require "iron_bank/schema"
require "iron_bank/query_builder"
require "iron_bank/payment_run"
require "iron_bank/user"

# Operations
require "iron_bank/operation"
require "iron_bank/operations/billing_preview"

# Resources
require "iron_bank/associations"
require "iron_bank/metadata"
require "iron_bank/queryable"
require "iron_bank/resource"
require "iron_bank/collection"
require "iron_bank/resources/account"
require "iron_bank/resources/amendment"
require "iron_bank/resources/communication_profile"
require "iron_bank/resources/contact"
require "iron_bank/resources/export"
require "iron_bank/resources/import"
require "iron_bank/resources/invoice_adjustment"
require "iron_bank/resources/invoice_item"
require "iron_bank/resources/invoice_payment"
require "iron_bank/resources/invoice"
require "iron_bank/resources/payment_method"
require "iron_bank/resources/payment"
require "iron_bank/resources/product_rate_plan_charge_tier"
require "iron_bank/resources/product_rate_plan_charge"
require "iron_bank/resources/product_rate_plan"
require "iron_bank/resources/product"
require "iron_bank/resources/rate_plan_charge_tier"
require "iron_bank/resources/rate_plan_charge"
require "iron_bank/resources/rate_plan"
require "iron_bank/resources/subscription"
require "iron_bank/resources/taxation_item"
require "iron_bank/resources/usage"

# Aliasing IronBank::Actions::* to IronBank::*
IronBank::Actions.constants.each do |action|
  IronBank.const_set(action, IronBank::Actions.const_get(action))
end

# Aliasing IronBank::Resources::* to IronBank::*
IronBank::Resources.constants.each do |resource|
  IronBank.const_set(resource, IronBank::Resources.const_get(resource))
end

# Aliasing catalog-related objects
IronBank::CatalogPlan   = IronBank::Resources::ProductRatePlan
IronBank::CatalogCharge = IronBank::Resources::ProductRatePlanCharge
IronBank::CatalogTier   = IronBank::Resources::ProductRatePlanChargeTier

# Aliasing subscription-related objects
IronBank::Plan   = IronBank::Resources::RatePlan
IronBank::Charge = IronBank::Resources::RatePlanCharge
IronBank::Tier   = IronBank::Resources::RatePlanChargeTier
