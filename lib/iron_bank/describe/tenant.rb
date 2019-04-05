# frozen_string_literal: true

module IronBank
  module Describe
    # Describe a Zuora tenant, including its objects.
    #
    class Tenant
      private_class_method :new

      def self.from_xml(doc)
        new(doc)
      end

      def self.from_connection(connection)
        xml = connection.get("v1/describe").body
        new(Nokogiri::XML(xml), connection)
      rescue TypeError
        # NOTE: Zuora returns HTTP 401 (unauthorized) roughly 1 out of 3 times
        # we make this call. Since this is a setup-only call and not a runtime
        # one, we deemed it acceptable to keep retrying until it works.
        retry
      end

      def objects
        return object_names unless connection

        @objects ||= object_names.map do |name|
          IronBank::Describe::Object.from_connection(connection, name)
        end
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)}>"
      end

      private

      attr_reader :doc, :connection

      def initialize(doc, connection = nil)
        @doc        = doc
        @connection = connection
      end

      def object_names
        @object_names ||= doc.xpath(".//object/name").map(&:text)
      end
    end
  end
end
