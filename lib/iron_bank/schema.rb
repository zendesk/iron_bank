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
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
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
      @import = nil
    end

    def export
      tenant.objects.compact.each do |object|
        begin
          object.export
        rescue IronBank::Describe::Object::InvalidXML
          # TODO: log the object error
          next
        end
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
