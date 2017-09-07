require 'ostruct'
require 'yaml'
require 'erb'

module RSpectacles
  class Config
    def initialize
      @opts = OpenStruct.new defaults.merge(yml.symbolize_keys)
    end

    def defaults
      {
        sinatra_port: ENV['RSPECTACLES_PORT'] || ENV['PORT'] || 4567,
        batch_size: (ENV['RSPECTACLES_BATCH_SIZE'] || 100).to_i,
        last_run_primary_key: ENV['RSPECTACLES_LAST_RUN_KEY'] || ENV['CIRCLE_BUILD_NUM'] || 'rspec-last-run',
        rspectacles_url: ENV['RSPECTACLES_URL']
      }
    end

    def method_missing(method, *args)
      @opts.send method, *args
    end

    private

    def yml_path
      ::File.expand_path(ENV['RSPECTACLES_CONFIG']) if ENV['RSPECTACLES_CONFIG']
    end

    def yml_exists?
      yml_path && ::File.exist?(yml_path)
    end

    def yml
      if yml_exists?
        @yml ||= ::YAML.load(::ERB.new(IO.read(yml_path)).result)
      else
        {}
      end
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
