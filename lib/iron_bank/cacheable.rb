# frozen_string_literal: true

module IronBank
  # Use the provided cache if present.
  #
  module Cacheable
    def reload
      remove_instance_vars
      @remote = self.class.find(id, force: true).remote
      self
    end

    private

    def remove_instance_vars
      # Substract predefined variables from the instance variables
      (instance_variables - [:@remote]).each do |var|
        remove_instance_variable(:"#{var}")
      end
    end

    def cache
      self.class.cache
    end

    # Override queryable class methods to use cache if present.
    #
    module ClassMethods
      def find(id, force: false)
        return super(id) unless cache

        cache.fetch(id, force: force) { super(id) }
      end

      def where(conditions, limit: 0)
        # Conditions can be empty when called from #all, it does not make sense
        # to try to cache all records returned then.
        return super if conditions.empty?

        return super unless cache

        # Ensure we are not colliding when the conditions are similar for two
        # different resources, like Account and Subscription.
        cache_key = conditions.merge(object_name: name)
        cache.fetch(cache_key) { super }
      end

      def cache
        IronBank.configuration.cache
      end
    end
  end
end
