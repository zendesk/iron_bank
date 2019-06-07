# frozen_string_literal: true

module IronBank
  # A custom CSV converter
  #
  class CSV < ::CSV
    DECIMAL_INTEGER_REGEX = /^[+-]?\d+$/.freeze
    DECIMAL_FLOAT_REGEX   = /^[+-]?(?:\d*\.|\.\d*)\d*$/.freeze

    CSV::Converters[:decimal_integer] = lambda do |field|
      return field unless field

      encoding = field.encode(CSV::ConverterEncoding)

      # Match: [1, 10, 100], No match: [0.1, .1, 1., 0b10]
      DECIMAL_INTEGER_REGEX.match?(encoding) ? encoding.to_i : field
    end

    CSV::Converters[:decimal_float] = lambda do |field|
      return field unless field

      encoding = field.encode(CSV::ConverterEncoding)

      # Match: [1.0, 1., 0.1, .1], No match: [1, 0b10]
      DECIMAL_FLOAT_REGEX.match?(encoding) ? encoding.to_f : field
    end
  end
end
