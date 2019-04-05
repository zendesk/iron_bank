# frozen_string_literal: true

module IronBank
  # An Iron Bank RESTful resource.
  #
  class Resource
    include IronBank::Associations
    extend IronBank::Associations::ClassMethods
    extend IronBank::Metadata
    extend IronBank::Queryable

    def self.object_name
      name.split("::").last
    end

    def self.with_local_records
      extend IronBank::Local
    end

    def self.with_cache
      include IronBank::Cacheable
      extend IronBank::Cacheable::ClassMethods
    end

    attr_reader :remote

    def initialize(remote = {})
      @remote = remote
    end

    # Every Zuora object has an ID, so we can safely declare it for each
    # resource
    def id
      remote[:id]
    end

    def inspect
      # NOTE: In Ruby, the IDs of objects start from the second bit on the right
      # but in "value space" (used by the original `inspect` implementation)
      # they start from the third bit on the right. Hence the bitsfhit operation
      # here.
      # https://stackoverflow.com/questions/2818602/in-ruby-why-does-inspect-print-out-some-kind-of-object-id-which-is-different
      ruby_id = "#{self.class.name}:0x#{(object_id << 1).to_s(16)} id=\"#{id}\""
      respond_to?(:name) ? "#<#{ruby_id} name=\"#{name}\">" : "#<#{ruby_id}>"
    end

    # Two resources are equals if their remote (from Zuora) data are similar
    def ==(other)
      other.is_a?(IronBank::Resource) ? remote == other.remote : false
    end

    def reload
      remove_instance_vars
      @remote = self.class.find(id).remote
    end

    def to_csv_row
      self.class.fields.each.with_object([]) do |field, row|
        row << remote[IronBank::Utils.underscore(field).to_sym]
      end
    end

    def remove_instance_vars
      # Substract predefined variables from the instance variables
      (instance_variables - [:@remote]).each do |var|
        remove_instance_variable(:"#{var}")
      end
    end
  end
end
