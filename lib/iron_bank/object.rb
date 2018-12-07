# frozen_string_literal: true

module IronBank
  # This object holds the initial payload sent to an action/operation. It
  # exposes methods to convert the payload keys to either upper camel case
  # (typically used by actions) or lower camel case.
  #
  # It is also use to parse the response from Zuora and convert it into a Ruby-
  # friendly Hash.
  #
  class Object
    UNMODIFIED_FIELD_KEYS = %w[
      fieldsToNull
    ].freeze

    CAMELIZER = lambda do |type, key|
      return key if UNMODIFIED_FIELD_KEYS.include?(key.to_s)

      IronBank::Utils.camelize(key, type: type)
    end

    UNDERSCORER = lambda do |key|
      IronBank::Utils.underscore(key).to_sym
    end

    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def deep_camelize(type: :upper)
      @prok = CAMELIZER.curry[type]

      transform(payload)
    end

    def deep_underscore
      @prok = UNDERSCORER

      transform(payload)
    end

    private

    attr_reader :prok

    def transform(value)
      case value
      when Array            then transform_array(value)
      when Hash             then transform_hash(value)
      when IronBank::Object then transform(value.payload)
      else                       value
      end
    end

    def transform_array(array)
      array.map { |element| transform(element) }
    end

    def transform_hash(hash)
      hash.each.with_object({}) do |(key, value), hsh|
        key = prok.call(key.to_s)

        hsh[key] = transform(value)
      end
    end
  end
end
