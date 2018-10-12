# frozen_string_literal: true

module IronBank
  # Handle the credentials to Zuora and establish a connection when making an
  # authenticated request, reusing the same session cookie for future requests.
  #
  class Client
    include IronBank::Instrumentation
    include IronBank::OpenTracing

    # Generic client error.
    #
    class Error < StandardError; end

    # Thrown when the base_url cannot be found for the given domain.
    #
    class InvalidHostname < Error; end

    # Alias each actions as a `Client` instance method
    IronBank::Actions.constants.each do |action|
      method_name = IronBank::Utils.underscore(action)
      klass       = IronBank::Actions.const_get(action)

      define_method :"#{method_name}" do |args|
        klass.call(args)
      end
    end

    def initialize(domain:, client_id:, client_secret:, auth_type: 'token')
      @domain        = domain
      @client_id     = client_id
      @client_secret = client_secret
      @auth_type     = auth_type
    end

    def inspect
      %(#<IronBank::Client:0x#{(object_id << 1).to_s(16)} domain="#{domain}">)
    end

    def connection
      validate_domain
      reset_connection if auth.expired?

      @connection ||= Faraday.new(faraday_config) do |conn|
        conn.use      :ddtrace, open_tracing_options if open_tracing_enabled?
        conn.use      instrumenter, instrumenter_options if instrumenter
        conn.request  :json
        conn.request  :retry, max: 2, exceptions: [IronBank::Unauthorized]
        conn.use      :raise_error
        conn.request  :retriable_auth, auth
        conn.response :logger, IronBank.logger
        conn.response :json, content_type: /\bjson$/
        conn.adapter  Faraday.default_adapter
      end
    end

    def describe(object_name)
      IronBank::Describe::Object.from_connection(connection, object_name)
    end

    private

    attr_reader :domain, :client_id, :client_secret, :auth_type

    def auth
      @auth ||= IronBank::Authentication.new(
        client_id:     client_id,
        client_secret: client_secret,
        base_url:      base_url,
        auth_type:     auth_type
      )
    end

    def base_url
      @base_url ||= IronBank::Endpoint.base_url(domain)
    end

    def faraday_config
      {
        url:     base_url,
        headers: headers
      }
    end

    def headers
      { 'Content-Type' => 'application/json' }.merge(auth.header)
    end

    def reset_connection
      @connection = nil
      auth.renew_session
    end

    def validate_domain
      raise InvalidHostname, domain.to_s unless base_url
    end
  end
end
