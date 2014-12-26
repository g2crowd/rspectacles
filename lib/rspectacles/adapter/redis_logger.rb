require 'rspectacles/config'
require 'redis'
require 'uri'
require 'json'

module RSpectacles
  module Adapter
    class RedisLogger
      attr_reader :redis

      def initialize
        @redis = ::Redis.new host: uri.host, port: uri.port, password: uri.password
      end

      def config
        RSpectacles.config
      end

      def uri
        @uri ||= URI.parse config.redis_uri
      end

      def delete_last_log
        redis.del config.last_run_primary_key
      end

      def log(message)
        redis.publish config.pubsub_channel_name, message
        redis.lpush config.last_run_primary_key, message
      end

      def log_formatted(example)
        message = format_example(example)
        redis.publish config.pubsub_channel_name, message
        redis.lpush config.last_run_primary_key, message
      end

      def format_example(example)
        {
          :description => example.description,
          :full_description => example.full_description,
          :status => example.execution_result.status,
          :duration => example.execution_result.run_time,
          :file_path => example.metadata[:file_path],
          :line_number  => example.metadata[:line_number]
        }.to_json
      end
    end
  end
end
