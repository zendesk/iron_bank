# frozen_string_literal: true

require "singleton"
require "logger"

module IronBank
  # Default logger for IronBank events
  #
  class Logger
    extend Forwardable

    PROGNAME = "iron_bank"
    LEVEL    = ::Logger::DEBUG

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    def initialize(logger: ::Logger.new($stdout), level: LEVEL)
      @logger          = logger
      @logger.progname = PROGNAME
      @logger.level    = level
    end
  end
end
