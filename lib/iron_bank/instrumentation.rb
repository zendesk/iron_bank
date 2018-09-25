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
  end
end
