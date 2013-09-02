require 'rubygems'
require 'sinatra/base'
require 'json'
require 'em-hiredis'
require 'uri'
require 'thin'
require 'pry'

# Helpers
# require './lib/render_partial'
# require './db/config'


module Rspectacles
  class App < Sinatra::Base
    connections = []
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

    uri = URI.parse 'redis://127.0.0.1:6379/'
    emredis = nil

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

    def path_prefix
      request.env['SCRIPT_NAME']
    end

    EM.next_tick do
      emredis = EM::Hiredis.connect(uri)

      emredis.pubsub.subscribe 'redis-rspec-examples' do |message|
        connections.each { |out| out << "data: #{message}\n\n" }
      end
    end
  end
end

