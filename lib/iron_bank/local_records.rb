# frozen_string_literal: true

module IronBank
  # Utility class to save records locally.
  #
  class LocalRecords
    private_class_method :new

    RESOURCE_QUERY_FIELDS = {
      "Product"                   => ["*"],
      "ProductRatePlan"           => ["*", "Product.Id"],
      "ProductRatePlanCharge"     => ["*", "ProductRatePlan.Id"],
      "ProductRatePlanChargeTier" => ["*", "ProductRatePlanCharge.Id"]
    }.freeze

    def self.directory
      IronBank.configuration.export_directory
    end

    def self.export(max_attempts = 180)
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
      RESOURCE_QUERY_FIELDS.each_key { |resource| new(resource, max_attempts).save_file }
    end

    def save_file
      until completed? || max_query?
        IronBank.logger.info(export_query_info)
        sleep backoff_time
      end

      File.open(file_path, "w") do |file|
        file.write(export.content.force_encoding("UTF-8"))
      end
    end

    private

    BACKOFF = {
      interval: 5
    }.freeze

    private_constant :BACKOFF

    attr_reader :resource, :query_attempts, :query_max_attempts

    def initialize(resource, max_attempts)
      @resource           = resource
      @query_attempts     = 0
      @query_max_attempts = max_attempts
    end

    def export
      @export ||= IronBank::Export.create(
        "select #{RESOURCE_QUERY_FIELDS[resource].join(', ')} from #{resource}"
      )
    end

    def file_path
      File.expand_path("#{resource}.csv", self.class.directory)
    end

    def export_query_info
      "Waiting for export #{export.id} (#{resource}) to complete " \
        "(attempt #{query_attempts} of #{@query_max_attempts}; #{backoff_time}s " \
        "sleeping time)"
    end

    def completed?
      return false unless (status = export.reload.status)

      case status
      when "Pending", "Processing" then false
      when "Completed"             then true
      else                         raise_export_error
      end
    end

    def raise_export_error
      raise IronBank::Error, "Export #{export.id} has status #{export.status}"
    end

    def max_query?
      @query_attempts += 1
      return false unless @query_attempts > @query_max_attempts

      raise IronBank::Error, "Export query attempts exceeded"
    end

    def backoff_time
      BACKOFF[:interval]
    end
  end
end
