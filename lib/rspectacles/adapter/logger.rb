require 'rspectacles/config'
require 'uri'
require 'json'
require 'httparty'

module RSpectacles
  module Adapter
    class Logger
      attr_reader :test_run_key

      def initialize(test_run_key: nil)
        @test_run_key = test_run_key || config.last_run_primary_key
      end

      def config
        RSpectacles.config
      end

      def uri
        @uri ||= config.rspectacles_url
      end

      def stop
      end

      def start
      end

      def log(example)
        message = format_example(example)
        queue message
      end

      private

      def queue(message)
        return unless active?
        post_results Array.wrap(message)
      end

      def post_results(messages)
        HTTParty.post(full_uri, timeout: 5,
                                body: { examples: messages }.to_json,
                                headers: { 'Content-Type' => 'application/json' })
      rescue Net::ReadTimeout
        puts "RSpectacles Timeout! Failed to send #{messages.size} messages"
      end

      def active?
        !!uri
      end

      def full_uri
        "#{uri}/examples"
      end

      def format_example(example)
        {
          rspec_run: test_run_key,
          description: example.description,
          full_description: example.full_description,
          status: example.execution_result.status,
          duration: example.execution_result.run_time,
          file_path: example.metadata[:file_path],
          line_number: example.metadata[:line_number]
        }
      end
    end
  end
end
