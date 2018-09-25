# frozen_string_literal: true

module IronBank
  module Operations
    # Delete one or more objects of the same type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTdelete
    #
    class BillingPreview < Operation
      private

      def params
        IronBank::Object.new(args).deep_camelize(type: :lower)
      end
    end
  end
end
