require 'rspectacles/adapter/batched_redis_logger'
require 'rspectacles/formatter/redis'

module RSpectacles
  module Formatter
    class BatchedRedis < RSpectacles::Formatter::Redis
      RSpec::Core::Formatters.register self,
                                       *%i(example_passed
                                           example_failed
                                           start
                                           stop
                                           message)

      def logger
        @logger ||= RSpectacles::Adapter::BatchedRedisLogger.new(test_run_key: current_run_key)
      end
    end
  end
end
