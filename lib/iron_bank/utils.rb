# frozen_string_literal: true

module IronBank
  # A few helper methods for interacting with Zuora
  #
  module Utils
    module_function

    # Inspired from ActiveSupport
    def underscore(camel_cased_word)
      return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)

      word = camel_cased_word.to_s.gsub(/::/, "/")
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase
    end

    def camelize(term, type: :upper)
      # Preserve custom field term postfix, in the '__c' or the '__NS' format
      custom_field   = (term.to_s =~ /__c$/i)
      netsuite_field = (term.to_s =~ /__NS$/i)
      lower_camelize = type == :lower

      output = term.to_s.dup.tap do |copy|
        copy.gsub!(/^_*/, "")
        copy.gsub!(/__(NS|c)$/i, "") if custom_field || netsuite_field

        lower_camelize ? lower_camelize(copy) : upper_camelize(copy)
      end

      if custom_field
        "#{output}__c"
      elsif netsuite_field
        "#{output}__NS"
      else
        output
      end
    end

    def kebab(term)
      underscore(term).tr!("_", "-")
    end

    def lower_camelize(term)
      term.gsub!(/(^|_)(.)/) do
        match = Regexp.last_match
        char  = match[2]

        match.begin(2).zero? ? char : char.upcase
      end
    end

    def upper_camelize(term)
      term.gsub!(/(^|_)(.)/) { Regexp.last_match(2).upcase }
    end
  end
end
