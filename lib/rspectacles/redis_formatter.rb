require 'rspec/core/formatters/base_formatter'
require 'ostruct'
require 'redis'

module RSpectacles
  class RedisFormatter < RSpec::Core::Formatters::BaseFormatter
    attr_accessor :redis

    class << self
      def config
        OpenStruct.new({
          channel_name: 'redis-rspec-examples',
          port: 6379,
          host: '127.0.0.1',
          password: ''
        })
      end
    end

    def initialize(output)
      self.redis = Redis.new host: config.host, port: config.port
    end

    def message(message)
      log "message:#{message}"
    end

    def start(example_count)
      log 'status:start'
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
      redis.flushall
    end

    private

    def config
      self.class.config
    end

    def log(message)
      redis.publish config.channel_name, message
    end

    def log_formatted(example)
      redis.publish config.channel_name, format_example(example)
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
