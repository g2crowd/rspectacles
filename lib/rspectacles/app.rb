require 'rubygems'
require 'sinatra/base'
require 'json'
require 'em-hiredis'
require 'redis'
require 'uri'
require 'thin'
require 'rspectacles/config.rb'

module RSpectacles
  class App < Sinatra::Base
    require 'rspectacles/app/helpers'

    connections = []
    config = RSpectacles.config
    dir = File.dirname(File.expand_path(__FILE__))
    set :app_file, __FILE__
    set :root, dir
    set :views, "#{dir}/app/views"
    set :static, true

    if respond_to? :public_folder
      set :public_folder, "#{dir}/app/public"
    else
      set :public, "#{dir}/app/public"
    end

    uri = URI.parse config.redis_uri
    redis = Redis.new host: uri.host, port: uri.port

    # Routes
    get '/' do
      erb :index
    end

    get '/stream', :provides => 'text/event-stream' do
      stream :keep_open do |out|
        connections << out
        out.callback { connections.delete(out) }
      end
    end

    get '/last' do
      redis.lrange(config.last_run_primary_key, 0, -1).to_json
    end

    # pubsub and streaming - EventMachine support only
    EM.next_tick do
      emredis = EM::Hiredis.connect(uri)

      emredis.pubsub.subscribe config.pubsub_channel_name do |message|
        connections.each { |out| out << "data: #{message}\n\n" }
      end
    end
  end
end
