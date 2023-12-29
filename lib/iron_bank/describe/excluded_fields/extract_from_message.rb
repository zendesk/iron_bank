# frozen_string_literal: true

module IronBank
  module Describe
    # Extracts invalid fields from an exception message.
    # Returns from a call if an exception message does not contain invalid field

    # rubocop:disable Style/ClassAndModuleChildren
    class ExcludedFields::ExtractFromMessage
      FAULT_FIELD_MESSAGES = Regexp.union(
        # Generic fault field
        /invalid field for query: \w+\.(\w+)/,
        # Invoice Bill Run is not selectable in ZOQL
        /Cannot use the (BillRunId) field in the select clause/,
        # Invoice Body, implemented as a separate call
        /Can only query one invoice (body) at a time/,
        # Catalog tier should only query the price field
        /use Price or (DiscountAmount) or (DiscountPercentage)/,
        # Catalog plan currencies, implemented as a separate call
        /When querying for (active currencies)/,
        # Catalog charge rollover balance
        /You can only query (RolloverBalance) in particular/,
        # (Subscription) charge should only query the price field
        /
          (OveragePrice),
          \ Price,
          \ (IncludedUnits),
          \ (DiscountAmount)
          \ or\ (DiscountPercentage)
        /x
      ).freeze

      private_class_method :new

      def self.call(message)
        new(message).call
      end

      def call
        return unless FAULT_FIELD_MESSAGES.match(message)

        Regexp.last_match.captures.compact.
          map { |capture| capture.delete(" ") }
      end

      private

      attr_reader :message

      def initialize(message)
        @message = message
      end
    end
    # rubocop:enable Style/ClassAndModuleChildren
  end
end
