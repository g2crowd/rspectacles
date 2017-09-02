require 'ostruct'
require 'yaml'
require 'erb'

module RSpectacles
  class Config
    def initialize
      @opts = OpenStruct.new defaults.merge(yml || {})
    end

    def defaults
      {
        sinatra_port: ENV['RSPECTACLES_PORT'] || ENV['PORT'] || 4567,
        batch_size: (ENV['RSPECTACLES_BATCH_SIZE'] || 100).to_i,
        pubsub_channel_name: ENV['RSPECTACLES_CHANNEL'] || 'redis-rspec-examples',
        last_run_primary_key: ENV['RSPECTACLES_LAST_RUN_KEY'] || 'redis-rspec-last-run',
        redis_uri: ENV['RSPECTACLES_REDIS_URL'] || 'redis://127.0.0.1:6379/'
      }
    end

    def method_missing(method, *args)
      @opts.send method, *args
    end

    private

    def yml_path
      if ENV['RSPECTACLES_CONFIG']
        ::File.expand_path(ENV['RSPECTACLES_CONFIG'])
      end
    end

    def yml_exists?
      yml_path && ::File.exist?(yml_path)
    end

    def yml
      @yml ||= ::YAML.load(::ERB.new(IO.read(yml_path)).result) if yml_exists?
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
