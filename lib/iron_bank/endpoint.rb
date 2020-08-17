# frozen_string_literal: true

module IronBank
  # Identify and return the proper base URL for a given Zuora domain.
  #
  class Endpoint
    private_class_method :new

    PRODUCTION  = /\Arest\.zuora\.com\z/i.freeze
    SERVICES    = /\A(rest)?services(\d+)\.zuora\.com(:\d+)?\z/i.freeze
    APISANDBOX  = /\Arest.apisandbox.zuora\.com\z/i.freeze

    def self.base_url(domain = "")
      new(domain).base_url
    end

    def base_url
      case domain
      when PRODUCTION
        "https://rest.zuora.com/"
      when SERVICES
        "https://#{domain}/".downcase
      when APISANDBOX
        "https://rest.apisandbox.zuora.com/"
      end
    end

    private

    attr_reader :domain

    def initialize(domain)
      @domain = domain
    end
  end
end
