# frozen_string_literal: true

module IronBank
  module Actions
    # Use the execute call to execute the process to split an invoice into
    # multiple invoices (the original invoice must be in draft status)
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTexecute
    #
    class Execute < Action
      private

      def params
        {
          ids:         args.fetch(:ids),
          synchronous: args.fetch(:synchronous),
          type:        type
        }
      end

      def type
        IronBank::Utils.camelize(args.fetch(:type), type: :upper)
      end
    end
  end
end
