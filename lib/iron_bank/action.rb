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
      @body = IronBank.client.connection.post(endpoint, params).body
      return body if success?

      raise ::IronBank::UnprocessableEntity, errors
    end

    private

    attr_reader :args, :body

    def initialize(args)
      @args = args
    end

    def endpoint
      "v1/action/#{name.downcase}"
    end

    def name
      self.class.name.split('::').last
    end

    def success?
      response_object.fetch(:success, true)
    end

    def response_object
      @response_object ||= begin
        return {} unless body.is_a?(Array)

        ::IronBank::Object.new(body.first).deep_underscore
      end
    end

    def errors
      { errors: response_object.fetch(:errors, []) }
    end

    def requests(type: :upper)
      args.fetch(:objects).map do |object|
        IronBank::Object.new(object).deep_camelize(type: type)
      end
    end
  end
end
