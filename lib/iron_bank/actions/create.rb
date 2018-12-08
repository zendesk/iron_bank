# frozen_string_literal: true

module IronBank
  module Actions
    # Create one or more objects of a specific type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTcreate
    #
    class Create < Action
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
