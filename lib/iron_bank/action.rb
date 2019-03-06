# frozen_string_literal: true

module IronBank
  # Base class for Zuora actions, e.g., subscribe
  #
  class Action
    include IronBank::Instrumentation

    private_class_method :new

    def self.call(args)
      new(args).call
    end

    def call
      datadog_instrumenter(name.downcase) do
        @body = IronBank.client.connection.post(endpoint, params).body

        raise ::IronBank::UnprocessableEntity, errors unless success?

        IronBank::Object.new(body).deep_underscore
      end
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
  end
end
