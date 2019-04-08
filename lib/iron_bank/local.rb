# frozen_string_literal: true

module IronBank
  # A local store for exported records.
  #
  module Local
    def find(id)
      store[id] || super
    end

    def find_each
      return enum_for(:find_each) unless block_given?

      values = store.values
      values.any? ? values.each { |record| yield record } : super
    end

    def all
      store.any? ? store.values : super
    end

    def where(conditions)
      records = store.values.select do |record|
        conditions.all? { |field, value| record.public_send(field) == value }
      end

      records.any? ? records : super
    end

    def reset_store
      @store = nil
    end

    private

    # NOTE: Handle associations within the CSV export. E.g., when reading the
    #       `ProductRatePlan.csv` file, we have `ProductRatePlan.Id` and
    #       `Product.Id` fields. We want to end up with `id` and `product_id`
    #       respectively.
    def underscore_header
      lambda do |header|
        parts  = header.split(".")
        header = parts.first.casecmp?(object_name) ? parts.last : parts.join

        IronBank::Utils.underscore(header).to_sym
      end
    end

    def store
      @store ||= File.exist?(file_path) ? load_records : {}
    end

    def load_records
      CSV.foreach(file_path, csv_options).with_object({}) do |row, store|
        store[row[:id]] = new(row.to_h.compact)
      end
    end

    def csv_options
      {
        headers:           true,
        header_converters: [underscore_header],
        converters:        csv_converters
      }
    end

    def csv_converters
      %i[
        decimal_integer
        decimal_float
      ]
    end

    def file_path
      File.expand_path(
        "#{object_name}.csv",
        IronBank.configuration.export_directory
      )
    end
  end
end
