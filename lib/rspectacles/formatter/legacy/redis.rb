require 'rspec/core/formatters/base_formatter'
require 'rspectacles/adapter/redis_logger'

module RSpectacles
  module Formatter
    module Legacy
      class Redis < RSpec::Core::Formatters::BaseFormatter
        def initialize(_)
        end

        def logger
          @logger ||= RSpectacles::Adapter::RedisLogger.new
        end

        def message(message)
          logger.log "message:#{message}"
        end

        def start(example_count)
          logger.log 'status:start'
          logger.delete_last_log
        end

        def stop
          logger.log 'status:stop'
        end

        def example_started(example)
        end

        def example_passed(example)
          logger.log_formatted example
        end

        def example_pending(example)
          logger.log_formatted example
        end

        def example_failed(example)
          logger.log_formatted example
        end

        def close
        end
      end
    end
  end
end
