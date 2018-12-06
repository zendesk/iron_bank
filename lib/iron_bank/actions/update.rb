# frozen_string_literal: true

module IronBank
  module Actions
    # Update the information in one or more objects of the same type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTupdate
    #
    class Update < Action
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
