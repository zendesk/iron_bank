# frozen_string_literal: true

module IronBank
  # A custom CSV converter
  #
  class CSV < ::CSV
    CSV::Converters[:decimal_integer] = lambda { |field|
      begin
        encoding = field.encode(CSV::ConverterEncoding)

        # Match: [1, 10, 100], No match: [0.1, .1, 1., 0b10]
        encoding =~ /^[+-]?\d+$/ ? encoding.to_i : field
      rescue # encoding or integer conversion
        field
      end
    }

    CSV::Converters[:decimal_float] = lambda { |field|
      begin
        encoding = field.encode(CSV::ConverterEncoding)

        # Match: [1.0, 1., 0.1, .1], No match: [1, 0b10]
        encoding =~ /^[+-]?(?:\d*\.|\.\d*)\d*$/ ? encoding.to_f : field
      rescue # encoding or float conversion
        field
      end
    }
  end
end
