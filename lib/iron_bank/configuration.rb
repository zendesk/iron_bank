# frozen_string_literal: true

module IronBank
  # The Zuora configuration class.
  #
  class Configuration
    # middlewares
    attr_accessor :middlewares

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

    # File path for excluded fields (when querying using ZOQL)
    attr_accessor :excluded_fields_file

    # Directory where the XML describe files are located.
    attr_reader :schema_directory

    # Directory where the local records are exported.
    attr_reader :export_directory

    # File path for Zuora users export
    attr_accessor :users_file

    # Specify a minor version
    attr_accessor :api_minor_version

    def initialize
      @schema_directory   = "./config/schema"
      @export_directory   = "./config/export"
      @logger             = IronBank::Logger.new
      @auth_type          = "token"
      @middlewares        = []
      @api_minor_version  = "211.0"
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

      IronBank::LocalRecords::RESOURCE_QUERY_FIELDS.each_key do |resource|
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

    def excluded_fields
      return {} unless excluded_fields_file

      unless File.exist?(excluded_fields_file)
        IronBank.logger.warn "File does not exist: #{excluded_fields_file}"

        return {}
      end

      @excluded_fields ||= Psych.load_file(excluded_fields_file).tap do |fields|
        raise "Excluded fields must be a hash" unless fields.is_a?(Hash)
      end
    end
  end
end
