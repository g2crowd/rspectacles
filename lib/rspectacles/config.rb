require 'ostruct'
require 'yaml'

module RSpectacles
  class Config
    def initialize
      user_options = load_user_opts
      @opts = OpenStruct.new defaults.merge(user_options)
    end

    def defaults
      {
        sinatra_port: 4567,
        pubsub_channel_name: 'redis-rspec-examples',
        last_run_primary_key: 'redis-rspec-last-run',
        redis_uri: 'redis://127.0.0.1:6379/'
      }
    end

    def load_user_opts
      if ENV['RSPECTACLES_CONFIG'] && ::File.exists?(::File.expand_path(ENV['RSPECTACLES_CONFIG']))
        YAML.load_file(::File.expand_path(ENV['RSPECTACLES_CONFIG']))
      else
        {}
      end
    end

    def method_missing(method, *args)
      @opts.send method, *args
    end
  end

  def self.configuration
    @configuration ||= Config.new
  end

  def self.config
    yield configuration if block_given?
    configuration
  end
end
