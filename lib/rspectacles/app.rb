require 'rubygems'
require 'sinatra/base'
require 'json'
require 'em-hiredis'
require 'redis'
require 'uri'
require 'thin'

module RSpectacles
  class App < Sinatra::Base
    connections = []
    dir = File.dirname(File.expand_path(__FILE__))
    $public_folder = "#{dir}/app/public"
    set :app_file, __FILE__
    set :root, dir
    set :views, "#{dir}/app/views"
    set :static, true

    if respond_to? :public_folder
      set :public_folder, $public_folder
    else
      set :public, $public_folder
    end

    uri = URI.parse 'redis://127.0.0.1:6379/'
    $emredis = nil
    $redis = Redis.new host: uri.host, port: uri.port

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
      $redis.lrange('redis-rspec-last-run', 0, -1).to_json
    end

    def dump_last_run(out)
      $emredis.lrange('redis-rspec-last-run', 0, -1) do |list|
        list.each { |msg| out << "data: #{msg}\n\n" }
      end
    end

    EM.next_tick do
      $emredis = EM::Hiredis.connect(uri)

      $emredis.pubsub.subscribe 'redis-rspec-examples' do |message|
        connections.each { |out| out << "data: #{message}\n\n" }
      end
    end

    helpers do
      def versioned_stylesheet(stylesheet)
        url "/css/#{stylesheet}.css?" + File.mtime(File.join($public_folder, "css", "#{stylesheet}.css")).to_i.to_s
      end

      def versioned_javascript(js)
        url "/js/#{js}.js?" + File.mtime(File.join($public_folder, "js", "#{js}.js")).to_i.to_s
      end
    end
  end
end

