# frozen_string_literal: true

module IronBank
  # The Zuora configuration class.
  #
  class Configuration
    # Instrumentation
    attr_accessor :instrumenter
    attr_accessor :instrumenter_options

    # Logger
    attr_accessor :logger

    # The Zuora domain for our tenant (apisandbox, production, etc.).
    attr_accessor :domain

    # OAuth client ID associated with our platform admin user.
    attr_accessor :client_id

    # OAuth client secret.
    attr_accessor :client_secret

    # Auth type (cookie|token)
    attr_accessor :auth_type

    # Cache store instance, optionally used by certain resources.
    attr_accessor :cache

    # Open Tracing
    attr_accessor :open_tracing_enabled

    # Open Tracing service name
    attr_accessor :open_tracing_service_name

    # Faraday retry options
    attr_writer :retry_options

    # Directory where the XML describe files are located.
    attr_reader :schema_directory

    # Directory where the local records are exported.
    attr_reader :export_directory

    def initialize
      @schema_directory          = "./config/schema"
      @export_directory          = "./config/export"
      @logger                    = IronBank::Logger.new
      @auth_type                 = "token"
      @open_tracing_enabled      = false
      @open_tracing_service_name = "ironbank"
    end

    def schema_directory=(value)
      @schema_directory = value

      return unless defined? IronBank::Schema

      IronBank::Schema.reset

      # Call `with_schema` on each resource to redefine accessors
      IronBank::Resources.constants.each do |resource|
        klass = IronBank::Resources.const_get(resource)
        klass.with_schema if klass.is_a?(Class)
      end
    end

    def export_directory=(value)
      @export_directory = value
      return unless defined? IronBank::Product

      IronBank::LocalRecords::RESOURCES.each do |resource|
        IronBank::Resources.const_get(resource).reset_store
      end
    end

    def credentials
      {
        domain:        domain,
        client_id:     client_id,
        client_secret: client_secret,
        auth_type:     auth_type
      }
    end

    def credentials?
      credentials.values.all?
    end

    def retry_options
      @retry_options ||= IronBank::Client::DEFAULT_RETRY_OPTIONS
    end
  end
end
