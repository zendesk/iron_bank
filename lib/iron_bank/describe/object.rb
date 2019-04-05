# frozen_string_literal: true

module IronBank
  module Describe
    # Describe an object in Zuora: name, label, fields, etc.
    #
    class Object
      # Raised when the XML does not provide the expected node (see #name)
      #
      class InvalidXML < StandardError; end

      private_class_method :new

      def self.from_xml(doc)
        new(doc)
      end

      def self.from_connection(connection, name)
        xml = connection.get("v1/describe/#{name}").body
        new(Nokogiri::XML(xml))
      rescue TypeError
        # NOTE: Zuora returns HTTP 401 (unauthorized) roughly 1 out of 3 times
        #       we make this call. Since this is a setup-only call and not a
        #       runtime one, we deemed it acceptable to keep retrying until it
        #       works.
        retry
      rescue IronBank::InternalServerError
        # TODO: Need to properly store which object failed to be described by
        #       Zuora API and send a report to the console.
        nil
      end

      def export
        File.open(file_path, "w") { |file| file << doc.to_xml }
      end

      def name
        node = doc.at_xpath(".//object/name")
        raise InvalidXML unless node

        node.text
      end

      def label
        doc.at_xpath(".//object/label").text
      end

      def fields
        @fields ||= doc.xpath(".//fields/field").map do |node|
          IronBank::Describe::Field.from_xml(node)
        end
      end

      def query_fields
        @query_fields ||= fields.select(&:selectable?).map(&:name)
      end

      def related
        @related ||= doc.xpath(".//related-objects/object").map do |node|
          IronBank::Describe::Related.from_xml(node)
        end
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} #{name}>"
      end

      private

      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end

      def file_path
        File.expand_path "#{name}.xml", IronBank.configuration.schema_directory
      end
    end
  end
end
