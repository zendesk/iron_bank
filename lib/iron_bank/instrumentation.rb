# frozen_string_literal: true

module IronBank
  # Instrumentation helper module
  module Instrumentation
    def instrumenter
      IronBank.configuration.instrumenter
    end

    def instrumenter_options
      IronBank.configuration.instrumenter_options || {}
    end

    DDTRACE_NAME          = 'billing-ironbank'.freeze
    DDTRACE_SERVICE_NAME  = 'billing-ironbank-client'.freeze

    def datadog_instrumenter(name)
      if defined?(Datadog) && Datadog.respond_to?(:tracer)
        trace_options = {
          service:  DDTRACE_SERVICE_NAME,
          resource: name.to_s
        }

        Datadog.tracer.trace(DDTRACE_NAME, trace_options) { yield }
      else
        yield
      end
    end
  end
end
