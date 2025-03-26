# frozen_string_literal: true

module IronBank
  module Actions
    # Use the order operation to create subscriptions and make changes to subscriptions by creating orders
    # https://developer.zuora.com/v1-api-reference/api/operation/POST_Order/
    #
    class Order < Action
      private

      def endpoint
        "v1/orders"
      end

      def params
        base_order.tap do |order|
          optional_keys.each do |key, method|
            order[key] = send(method) if args.key?(key)
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def optional_keys
        {
          category:              :fetch_category,
          newAccount:            :fetch_new_account,
          existingAccountNumber: :fetch_existing_account_number,
          customFields:          :fetch_custom_fields,
          reasonCode:            :fetch_reason_code,
          status:                :fetch_status,
          orderLineItems:        :fetch_order_line_items,
          processingOptions:     :fetch_processing_options,
          schedulingOptions:     :fetch_scheduling_options
        }
      end
      # rubocop:enable Metrics/MethodLength

      def fetch_category
        args[:category]
      end

      def fetch_new_account
        IronBank::Object.new(args.fetch(:newAccount)).deep_camelize(type: :lower)
      end

      def fetch_existing_account_number
        args[:existingAccountNumber]
      end

      def fetch_custom_fields
        IronBank::Object.new(args.fetch(:customFields)).deep_camelize(type: :upper)
      end

      def fetch_reason_code
        args[:reasonCode]
      end

      def fetch_status
        args[:status]
      end

      def fetch_order_line_items
        IronBank::Object.new(args.fetch(:orderLineItems)).deep_camelize(type: :lower)
      end

      def fetch_processing_options
        IronBank::Object.new(args.fetch(:processingOptions)).deep_camelize(type: :lower)
      end

      def fetch_scheduling_options
        IronBank::Object.new(args.fetch(:schedulingOptions)).deep_camelize(type: :lower)
      end

      def subscriptions
        IronBank::Object.new(args.fetch(:subscriptions)).deep_camelize(type: :lower)
      end

      def base_order
        {
          orderDate:     args.fetch(:orderDate),
          subscriptions: subscriptions
        }
      end
    end
  end
end
