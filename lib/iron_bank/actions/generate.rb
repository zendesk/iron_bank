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
          objects: objects,
          type:    type
        }
      end

      def objects
        IronBank::Object.new(args.fetch(:objects)).deep_camelize(type: :upper)
      end

      def type
        IronBank::Utils.camelize(args.fetch(:type), type: :upper)
      end
    end
  end
end
