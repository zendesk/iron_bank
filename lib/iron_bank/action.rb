# frozen_string_literal: true

module IronBank
  # Base class for Zuora actions, e.g., subscribe
  #
  class Action
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
      "v1/action/#{name.downcase}"
    end

    def name
      self.class.name.split('::').last
    end

    def requests(type: :upper)
      args.fetch(:objects).map do |object|
        IronBank::Object.new(object).deep_camelize(type: type)
      end
    end
  end
end
