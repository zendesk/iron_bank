# frozen_string_literal: true

module IronBank
  module Actions
    # Query Zuora using ZOQL
    # https://knowledgecenter.zuora.com/DC_Developers/K_Zuora_Object_Query_Language
    #
    class Query < Action
      DEFAULT_ZUORA_LIMIT = 0

      def self.call(zoql, limit: DEFAULT_ZUORA_LIMIT)
        new(zoql, limit).call
      end

      private

      attr_reader :zoql, :limit

      def initialize(zoql, limit)
        @zoql  = zoql
        @limit = limit
      end

      def params
        return required_params if limit.zero?

        required_params.merge(conf: { batchSize: limit })
      end

      def required_params
        { queryString: zoql }
      end
    end
  end
end
