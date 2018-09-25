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

    def store
      @store ||= File.exist?(file_path) ? load_records : {}
    end

    def load_records
      CSV.foreach(file_path, csv_options).with_object({}) do |row, store|
        # NOTE: when we move away from Ruby 2.2.x and 2.3.x we can uncomment
        # this line, delete the other one, since `Hash#compact` is available in
        # 2.4.x and we can remove two smells from `.reek` while we are at it
        #
        # store[row['Id']] = new(row.to_h.compact)
        store[row['Id']] = new(row.to_h.reject { |_, value| value.nil? })
      end
    end

    def csv_options
      {
        headers:    true,
        converters: csv_converters
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
