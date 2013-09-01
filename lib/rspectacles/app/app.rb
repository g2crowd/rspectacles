require 'rubygems'
require 'sinatra/base'
require 'json'
require 'em-hiredis'
require 'uri'
require 'thin'

# Helpers
# require './lib/render_partial'
# require './db/config'


EM.run do
  class App < Sinatra::Base
    connections = []
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :views, File.expand_path('../views', __FILE__)
    set :public_folder, File.expand_path('../public', __FILE__)

    uri = URI.parse 'redis://127.0.0.1:6379/'
    emredis = EM::Hiredis.connect(uri)

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

    emredis.pubsub.subscribe 'redis-rspec-examples' do |message|
      connections.each { |out| out << "data: #{message}\n\n" }
    end
  end

  Thin::Server.start App, '0.0.0.0', 4567
end
