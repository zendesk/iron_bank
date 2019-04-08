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
      RESOURCES.each { |resource| new(resource).save_file }
    end

    def save_file
      until completed? || max_query?
        IronBank.logger.info(export_query_info)
        sleep backoff_time
      end

      File.open(file_path, "w") { |file| file.write(export.content) }
    end

    private

    BACKOFF = {
      max:                 3,
      interval:            0.5,
      interval_randomness: 0.5,
      backoff_factor:      4
    }.freeze
    private_constant :BACKOFF

    attr_reader :resource, :query_attempts

    def initialize(resource)
      @resource       = resource
      @query_attempts = 0
    end

    def export
      @export ||= IronBank::Export.create("select * from #{resource}")
    end

    def file_path
      File.expand_path("#{resource}.csv", self.class.directory)
    end

    def export_query_info
      "Waiting for export #{export.id} to complete " \
        "(attempt #{query_attempts} of #{BACKOFF[:max]})"
    end

    def completed?
      return false unless (status = export.reload.status)

      case status
      when "Pending", "Processing" then false
      when "Completed"             then true
      else
        raise IronBank::Error, "Export #{export.id} has status #{export.status}"
      end
    end

    def max_query?
      @query_attempts += 1
      return false unless @query_attempts > BACKOFF[:max]

      raise IronBank::Error, "Export query attempts exceeded"
    end

    def backoff_time
      backoff_interval = BACKOFF[:interval]

      current_interval =
        backoff_interval * (BACKOFF[:backoff_factor]**query_attempts)

      random_interval =
        rand * BACKOFF[:interval_randomness].to_f * backoff_interval

      current_interval + random_interval
    end
  end
end
