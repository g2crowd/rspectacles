require 'rspec/core/formatters/base_formatter'
require 'rspectacles/config'
require 'ostruct'
require 'redis'
require 'uri'

module RSpectacles
  class RedisFormatter < RSpec::Core::Formatters::BaseFormatter
    attr_accessor :redis

    class << self
      def config
        RSpectacles.config
      end
    end

    def initialize(output)
      uri = URI.parse config.redis_uri
      self.redis = Redis.new host: uri.host, port: uri.port, password: uri.password
    end

    def message(message)
      log "message:#{message}"
    end

    def start(example_count)
      log 'status:start'
      redis.del config.last_run_primary_key
    end

    def stop
      log 'status:stop'
    end

    def example_started(example)
    end

    def example_passed(example)
      log_formatted example
    end

    def example_pending(example)
      log_formatted example
    end

    def example_failed(example)
      log_formatted example
    end

    def close
    end

    private

    def config
      self.class.config
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
        :status => example.execution_result[:status],
        :duration => example.execution_result[:run_time],
        :file_path => example.metadata[:file_path],
        :line_number  => example.metadata[:line_number]
      }.to_json
    end
  end
end
