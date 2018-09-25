# frozen_string_literal: true

module IronBank
  # Define association methods for Zuora resources.
  #
  module Associations
    # Define class methods
    #
    module ClassMethods
      def with_one(name, options = {})
        resource_name = options.fetch(
          :resource_name,
          IronBank::Utils.camelize(name)
        )
        foreign_key = options.fetch(:foreign_key, name.to_s + '_id')

        define_method(name) do
          return unless (foreign_key_value = public_send(foreign_key))

          with_memoization(name) do
            # NOTE: we retrieve the constant here to prevent the need to order
            # our `require <file>` statements in `iron_bank.rb`
            klass = IronBank::Resources.const_get(resource_name)
            klass.find(foreign_key_value)
          end
        end

        # Association is "also known as"
        aka = options[:aka]
        alias_method aka, name if aka
      end

      def with_many(name, options = {})
        resource_name = options.fetch(
          :resource_name,
          IronBank::Utils.camelize(name.to_s.chop)
        )

        foreign_key = options.fetch(
          :foreign_key,
          IronBank::Utils.underscore(object_name) + '_id'
        )

        define_method(name) do
          with_memoization(name) do
            # NOTE: we retrieve the constant here to prevent the need to order
            # our `require <file>` statements in `iron_bank.rb`
            klass      = IronBank::Resources.const_get(resource_name)
            conditions = options.fetch(:conditions, {}).
                         merge("#{foreign_key}": id)
            items      = klass.where(conditions)
            IronBank::Collection.new(klass, conditions, items)
          end
        end

        # Association is "also known as"
        aka = options[:aka]
        alias_method aka, name if aka
      end
    end

    def with_memoization(name)
      # NOTE: We use `instance_variables.include?` instead of `defined?`.
      # Later it will always evaluate to `true` because it's an expression.
      if instance_variables.include?(:"@#{name}")
        return instance_variable_get(:"@#{name}")
      end

      memoizable = yield
      instance_variable_set(:"@#{name}", memoizable)
    end
  end
end
