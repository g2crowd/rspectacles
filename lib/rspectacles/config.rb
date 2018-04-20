require 'ostruct'
require 'yaml'
require 'erb'
require 'securerandom'

module RSpectacles
  class Config
    def initialize
      @opts = OpenStruct.new defaults.merge(yml)
    end

    def defaults
      {
        batch_size: (ENV['RSPECTACLES_BATCH_SIZE'] || 1000).to_i,
        last_run_primary_key: ENV['RSPECTACLES_RUN_KEY'] || ENV['CIRCLE_BUILD_NUM'] || SecureRandom.hex,
        timeout: (ENV['RSPECTACLES_TIMEOUT'] || 15).to_i,
        rspectacles_url: ENV['RSPECTACLES_URL']
      }
    end

    def timeout
      @opts[:timeout]
    end

    def method_missing(method, *args)
      @opts.public_send method, *args
    end

    private

    def yml_path
      ::File.expand_path(ENV['RSPECTACLES_CONFIG']) if ENV['RSPECTACLES_CONFIG']
    end

    def yml_exists?
      yml_path && ::File.exist?(yml_path)
    end

    def yml
      res = if yml_exists?
              @yml ||= ::YAML.safe_load(::ERB.new(IO.read(yml_path)).result)
            else
              {}
            end

      sanitize(res)
    end

    def sanitize(hash)
      hash.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value }
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
