# frozen_string_literal: true

module IronBank
  module Describe
    # Describe a field in Zuora: name, label, type, etc.
    #
    class Field
      private_class_method :new

      TEXT_VALUES = %i[
        name
        label
        type
      ].freeze

      PLURAL_VALUES = %i[
        options
        contexts
      ].freeze

      BOOLEAN_VALUES = %i[
        selectable
        createable
        updateable
        filterable
        custom
        required
      ].freeze

      def self.from_xml(doc)
        new(doc)
      end

      # Defined separately because the node name is not ruby-friendly
      def max_length
        doc.at_xpath('.//maxlength').text.to_i
      end

      TEXT_VALUES.each do |val|
        define_method(val) { doc.at_xpath(".//#{val}").text }
      end

      PLURAL_VALUES.each do |val|
        singular = val.to_s.chop
        define_method(val) { doc.xpath(".//#{val}/#{singular}").map(&:text) }
      end

      BOOLEAN_VALUES.each do |val|
        define_method(:"#{val}?") { doc.at_xpath(".//#{val}").text == 'true' }
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} #{name} (#{type})>"
      end

      private

      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end
    end
  end
end
