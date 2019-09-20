# frozen_string_literal: true

module IronBank
  # A Zuora user, only available if the user data has been exported and provided
  # to IronBank through the `users_file` configuration option.
  #
  # Cf. https://knowledgecenter.zuora.com/CF_Users_and_Administrators/A_Administrator_Settings/Manage_Users#Export_User_Data_to_a_CSV_File
  #
  class User
    extend IronBank::Local
    extend SingleForwardable

    def_delegators "IronBank.configuration", :users_file

    class << self
      def store
        return {} unless users_file

        @store ||= begin
          if File.exist?(users_file)
            load_records
          else
            IronBank.logger.warn "File does not exist: #{users_file}"
            {}
          end
        end
      end

      def load_records
        CSV.foreach(users_file, headers: true).with_object({}) do |row, store|
          store[row["User ID"]] = new(row.to_h.compact)
        end
      end

      def all
        store.values
      end

      def find(user_id)
        store[user_id] || raise(IronBank::NotFoundError, "user id: #{user_id}")
      end
    end

    US_DATE_FORMAT = "%m/%d/%Y"

    FIELDS = [
      "User ID",
      "User Name",
      "First Name",
      "Last Name",
      "Status",
      "Work Email",
      "Created On",
      "Zuora Billing Role",
      "Zuora Payment Role",
      "Zuora Commerce Role",
      "Zuora Platform Role",
      "Zuora Finance Role",
      "Zuora Reporting Role",
      "Zuora Insights Role",
      "Last Login"
    ].freeze

    FIELDS.each do |field|
      method_name = IronBank::Utils.underscore(field.tr(" ", ""))

      define_method(method_name) do
        attributes[field]
      end
    end

    attr_reader :attributes

    alias id user_id

    def initialize(attributes)
      @attributes = attributes
    end

    def inspect
      ruby_id = "#{self.class.name}:0x#{(object_id << 1).to_s(16)} id=\"#{id}\""

      "#<#{ruby_id} user_name=\"#{user_name}\">"
    end

    def last_login
      @last_login ||= Date.strptime(attributes["Last Login"], US_DATE_FORMAT)
    end

    def created_on
      @created_on ||= Date.strptime(attributes["Created On"], US_DATE_FORMAT)
    end
  end
end
