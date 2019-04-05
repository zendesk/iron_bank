# frozen_string_literal: true

module IronBank
  # Utility class to save records locally.
  #
  class LocalRecords
    private_class_method :new

    RESOURCES = %w[
      Product
      ProductRatePlan
      ProductRatePlanCharge
      ProductRatePlanChargeTier
    ].freeze

    def self.directory
      IronBank.configuration.export_directory
    end

    def self.export
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
      RESOURCES.each { |resource| new(resource).export }
    end

    def export
      CSV.open(file_path, "w") do |csv|
        # first row = CSV headers
        write_headers(csv)
        write_records(csv)
      end
    end

    private

    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def klass
      IronBank::Resources.const_get(resource)
    end

    def file_path
      File.expand_path("#{resource}.csv", self.class.directory)
    end

    def write_headers(csv)
      csv << klass.fields
    end

    def write_records(csv)
      klass.find_each { |record| csv << record.to_csv_row }
    end
  end
end
