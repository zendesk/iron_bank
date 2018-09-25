# frozen_string_literal: true

module IronBank
  module Actions
    # Generate an on-demand invoice for a specific customer
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTgenerate
    #
    class Generate < Action
      private

      def params
        {
          objects: args.fetch(:objects).map(&:deep_camelize),
          type:    args.fetch(:type)
        }
      end
    end
  end
end
