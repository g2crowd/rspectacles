require 'rspectacles/adapter/logger'

module RSpectacles
  module Adapter
    class BatchedLogger < Logger
      def queued_messages
        @queued_messages ||= []
      end

      def stop
        super
        flush_queue
      end

      def batch_size
        config.batch_size
      end

      def queue(message)
        return unless active?
        queued_messages << message
        flush_queue if queued_messages.count > batch_size
      end

      def flush_queue
        return unless active?
        return unless queued_messages.size > 0

        HTTParty.post(full_uri, timeout: 5,
                                body: { examples: queued_messages }.to_json,
                                headers: { 'Content-Type' => 'application/json' })

        @queued_messages = []
      end
    end
  end
end
