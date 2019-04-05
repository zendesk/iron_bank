# frozen_string_literal: true

module IronBank
  # Get a valid token or session HTTP request header for IronBank
  #
  class Authentication
    extend Forwardable

    attr_reader :session

    def_delegators :session, :header, :expired?

    def initialize(params)
      @auth_type = params.delete(:auth_type)
      @params    = params
      create_session
    end

    def create_session
      @session = adapter.new(params)
    end
    alias renew_session create_session

    private

    attr_reader :auth_type, :params

    def adapter
      @adapter ||=
        if auth_type == "cookie"
          IronBank::Authentications::Cookie
        else
          IronBank::Authentications::Token
        end
    end
  end
end
