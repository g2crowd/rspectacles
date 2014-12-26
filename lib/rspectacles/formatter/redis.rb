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

      def initialize(_)
      end

      def logger
        @logger ||= RSpectacles::Adapter::RedisLogger.new
      end

      def message(notification)
        logger.log "message:#{notification.message}"
      end

      def start(_)
        logger.log 'status:start'
        logger.delete_last_log
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
    end
  end
end
