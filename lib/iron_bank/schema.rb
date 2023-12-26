# frozen_string_literal: true

module IronBank
  # Representation of all Zuora objects and their fields for a Zuora tenant,
  # with import/export capabilities.
  #
  class Schema
    private_class_method :new

    def self.directory
      IronBank.configuration.schema_directory
    end

    def self.export
      FileUtils.mkdir_p(directory)
      new(IronBank.client).export
      reset
      import
    end

    def self.for(object_name)
      import[object_name]
    end

    def self.import
      @import ||= Dir["#{directory}/*.xml"].each.with_object({}) do |name, data|
        doc    = File.open(name) { |file| Nokogiri::XML(file) }
        object = IronBank::Describe::Object.from_xml(doc)
        data[object.name] = object
      end
    end

    def self.reset
      remove_instance_variable(:@import)

      IronBank::Resources.constants.each do |resource|
        IronBank::Resources.const_get(resource).reset
      end
    end

    def self.excluded_fields
      # NOTE: In some instances the error message from Zuora will not include the
      # unqueryable fields that need to be excluded. When that happens IronBank's
      # strategy will be to perform a binary search through the fields listed in the
      # query -- at the cost of performance due to repeated requests sent to Zuora
      # as it tries to identify the offending field.
      #
      # See:
      # - https://github.com/zendesk/iron_bank/pull/107
      @excluded_fields ||= IronBank::Resources.constants.each.with_object({}) do |resource, fields|
        fields[resource.to_s] =
          IronBank::Describe::ExcludedFields.call(object_name: resource)
      end
    end

    def export
      tenant.objects.compact.each do |object|
        object.export
      rescue IronBank::Describe::Object::InvalidXML
        # TODO: log the object error
        next
      end
    end

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def tenant
      @tenant ||= IronBank::Describe::Tenant.from_connection(client.connection)
    end
  end
end
