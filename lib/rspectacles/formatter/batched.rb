require 'rspectacles/adapter/batched_logger'
require 'rspectacles/formatter/base'

module RSpectacles
  module Formatter
    class Batched < RSpectacles::Formatter::Base
      RSpec::Core::Formatters.register self,
                                       *%i(example_passed
                                           example_failed
                                           start
                                           stop
                                           message)

      def logger
        @logger ||= RSpectacles::Adapter::BatchedLogger.new(test_run_key: current_run_key)
      end
    end
  end
end
