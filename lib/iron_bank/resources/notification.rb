# frozen_string_literal: true

module IronBank
  module Resources
    class Notification < Resource
      with_schema

      with_one :communication_profile

      ENDPOINT = "/notifications/notification-definitions"

      def self.find(id)
        raise IronBank::NotFoundError unless id
  
        response = IronBank.client.connection.get(
          "#{ENDPOINT}/#{id}"
        )
  
        new(IronBank::Object.new(response.body).deep_underscore)
      end
    end
  end
end
