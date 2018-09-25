# frozen_string_literal: true

module IronBank
  module Actions
    # Query Zuora using ZOQL
    # https://knowledgecenter.zuora.com/DC_Developers/K_Zuora_Object_Query_Language
    #
    class Query < Action
      private

      def params
        { 'queryString' => args }
      end
    end
  end
end
