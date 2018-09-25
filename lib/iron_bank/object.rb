# frozen_string_literal: true

module IronBank
  # This object holds the initial payload (hash) sent through one of the
  # action/operation. It exposes methods to convert the payload to either
  # upper camel case (typically used by actions) or lower camel case.
  #
  # It is also use to parse the response from Zuora and convert it into a Ruby-
  # friendly Hash.
  #
  class Object
    SNOWFLAKE_FIELDS = ['fieldsToNull'].freeze

    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    # FIXME: refactor both camelize/underscore methods into one
    def deep_camelize(type: :upper)
      payload.each_pair.with_object({}) do |(field, value), hash|
        field = field.to_s

        key = if SNOWFLAKE_FIELDS.include?(field)
                field
              else
                IronBank::Utils.camelize(field, type: type)
              end

        hash[key] = camelize(value, type: type)
      end
    end

    # FIXME: refactor both camelize/underscore methods into one
    def deep_underscore
      payload.each_pair.with_object({}) do |(field, value), hash|
        key       = IronBank::Utils.underscore(field.to_s).to_sym
        hash[key] = underscore(value)
      end
    end

    private

    # FIXME: refactor both camelize/underscore methods into one
    def camelize(value, type: :upper)
      if value.is_a?(Array)
        camelize_array(value, type: type)
      elsif value.is_a?(Hash)
        IronBank::Object.new(value).deep_camelize(type: type)
      elsif value.is_a?(IronBank::Object)
        value.deep_camelize(type: type)
      else
        value
      end
    end

    # FIXME: refactor both camelize/underscore methods into one
    def camelize_array(value, type: :upper)
      value.each.with_object([]) do |item, payload|
        item = IronBank::Object.new(item) if item.is_a?(Hash)
        item = item.deep_camelize(type: type) unless item.is_a?(String)

        payload.push(item)
      end
    end

    # FIXME: refactor both camelize/underscore methods into one
    def underscore(value)
      if value.is_a?(Array)
        underscore_array(value)
      elsif value.is_a?(Hash)
        IronBank::Object.new(value).deep_underscore
      elsif value.is_a?(IronBank::Object)
        value.deep_underscore
      else
        value
      end
    end

    # FIXME: refactor both camelize/underscore methods into one
    def underscore_array(value)
      value.each.with_object([]) do |item, payload|
        item = IronBank::Object.new(item) if item.is_a?(Hash)
        payload.push(item.deep_underscore)
      end
    end
  end
end
