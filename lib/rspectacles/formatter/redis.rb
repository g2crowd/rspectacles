require 'rspectacles/adapter/redis_logger'

module RSpectacles
  module Formatter
    class Redis
      RSpec::Core::Formatters.register self,
                                       *%i(example_passed
                                           example_failed
                                           start
                                           stop
                                           message)

      attr_reader :output

      def initialize(_)
      end

      def logger
        @logger ||= RSpectacles::Adapter::RedisLogger.new(test_run_key: current_run_key)
      end

      def message(notification)
        logger.log "message:#{notification.message}"
      end

      def start(_)
        logger.log 'status:start'
      end

      def stop(_)
        logger.log 'status:stop'
      end

      def example_passed(notification)
        logger.log_formatted notification.example
      end

      def example_pending(notification)
        logger.log_formatted notification.example
      end

      def example_failed(notification)
        logger.log_formatted notification.example
      end

      def current_run_key
        ENV['CURRENT_RSPEC_RUN'] || config.last_run_primary_key
      end

      def config
        RSpectacles.config
      end
    end
  end
end
