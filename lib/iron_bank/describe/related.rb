# frozen_string_literal: true

module IronBank
  module Describe
    # Describe a related object in Zuora, e.g., an account has a default payment
    # method
    #
    class Related
      private_class_method :new

      def self.from_xml(doc)
        new(doc)
      end

      def type
        @type ||= doc.attributes["href"].value.split("/").last
      end

      def name
        doc.at_xpath(".//name").text
      end

      def label
        doc.at_xpath(".//label").text
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
