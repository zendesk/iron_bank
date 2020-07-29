# frozen_string_literal: true

module IronBank
  class Instance
    attr_accessor :client, :configuration

    def initialize
      # @configuration ||= Configuration.new
      # yield(configuration)

      # return unless configuration.credentials?

      # @client ||= IronBank::Client.new(**configuration.credentials)
    end
  end
end
