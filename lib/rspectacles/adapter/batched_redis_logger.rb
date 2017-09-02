require 'rspectacles/adapter/redis_logger'

module RSpectacles
  module Adapter
    class BatchedRedisLogger < RedisLogger
      def queued_messages
        @queued_messages ||= []
      end

      def stop
        super
        flush_queue
      end

      def batch_size
        config.batch_size
      end

      def queue(message)
        queued_messages << message
        flush_queue if queued_messages.count > batch_size
      end

      def flush_queue
        queued_messages.each do |message|
          redis.publish config.pubsub_channel_name, message
          redis.lpush test_run_key, message
        end

        @queued_messages = []
      end
    end
  end
end
