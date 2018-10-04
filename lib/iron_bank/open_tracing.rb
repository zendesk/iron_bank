# frozen_string_literal: true

module IronBank
  # Open Tracing helper module
  module OpenTracing
    def open_tracing_enabled?
      IronBank.configuration.open_tracing_enabled
    end

    def open_tracing_options
      {
        distributed_tracing: true,
        split_by_domain:     false,
        service_name:        IronBank.configuration.open_tracing_service_name
      }
    end
  end
end
