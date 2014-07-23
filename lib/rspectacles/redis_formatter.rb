require 'rspec/core/formatters/base_formatter'
require 'rspectacles/config'
require 'ostruct'
require 'redis'
require 'uri'
require 'json'

module RSpectacles
  class RedisFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :message, :start, :stop, :close,
                                     :example_passed, :example_pending, :example_failed

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

    def message(notification)
      log "message:#{notification.message}"
    end

    def start(notification)
      log 'status:start'
      redis.del config.last_run_primary_key
    end

    def stop(notification)
      log 'status:stop'
    end

    def example_passed(notification)
      log_formatted notification.example
    end

    def example_pending(notification)
      log_formatted notification.example
    end

    def example_failed(notification)
      log_formatted notification.example
    end

    def close(notification)
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
        :status => example.execution_result.status,
        :duration => example.execution_result.run_time,
        :file_path => example.file_path,
        :line_number  => example.metadata[:line_number]
      }.to_json
    end
  end
end
