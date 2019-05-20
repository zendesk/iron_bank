# frozen_string_literal: true

module IronBank
  module Actions
    # Query Zuora using ZOQL
    # https://knowledgecenter.zuora.com/DC_Developers/K_Zuora_Object_Query_Language
    #
    class Query < Action
      def self.call(zoql, limit: 0)
        new(zoql, limit).call
      end

      private

      attr_reader :zoql, :limit

      def initialize(zoql, limit)
        @zoql  = zoql
        @limit = limit
      end

      def params
        if limit.zero?
          { queryString: zoql }
        else
          { queryString: zoql, conf: { batchSize: limit } }
        end
      end
    end
  end
end
