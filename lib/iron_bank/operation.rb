# frozen_string_literal: true

module IronBank
  # Base class for Zuora operations, e.g., billing preview
  #
  class Operation
    private_class_method :new

    def self.call(args)
      new(args).call
    end

    def call
      IronBank.client.connection.post(endpoint, params).body
    end

    private

    attr_reader :args

    def initialize(args)
      @args = args
    end

    def endpoint
      "v1/operations/#{IronBank::Utils.kebab(name)}"
    end

    def name
      self.class.name.split('::').last
    end
  end
end
