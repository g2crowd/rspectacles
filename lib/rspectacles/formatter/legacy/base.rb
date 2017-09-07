require 'rspec/core/formatters/base_formatter'
require 'rspectacles/adapter/logger'

module RSpectacles
  module Formatter
    module Legacy
      class Base < RSpec::Core::Formatters::BaseFormatter
        attr_reader :output

        def initialize(_)
        end

        def logger
          @logger ||= RSpectacles::Adapter::Logger.new
        end

        def message(_message)
        end

        def start(_example_count)
          logger.start
        end

        def stop
          logger.stop
        end

        def example_started(example)
        end

        def example_passed(example)
          logger.log example
        end

        def example_pending(example)
          logger.log example
        end

        def example_failed(example)
          logger.log example
        end

        def close
        end
      end
    end
  end
end
