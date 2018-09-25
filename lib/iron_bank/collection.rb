# frozen_string_literal: true

module IronBank
  # Collection class which allows records reloadable from the source
  class Collection
    include Enumerable
    extend Forwardable

    def_delegators :@records,
                   :[],
                   :each,
                   :length,
                   :size

    def initialize(klass, conditions, records)
      @klass = klass
      @conditions = conditions
      @records = records
    end

    # Update records from source
    def reload
      @records = @klass.where(@conditions)
    end

    # In case you need to access all array methods
    def to_a
      @records
    end
  end
end
