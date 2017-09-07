require 'rubygems'
require 'sinatra/base'
require 'json'
require 'sinatra/activerecord'
require 'thin'
require 'rspectacles/config.rb'
require 'rspectacles/app/models/example'

module RSpectacles
  class App < Sinatra::Base
    require 'rspectacles/app/helpers'
    register Sinatra::ActiveRecordExtension

    set :database_file, 'config/database.yml'

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

    # Routes
    get '/watch/:key' do
      erb :index
    end

    get '/watch' do
      params['key'] = config.last_run_primary_key
      erb :index
    end

    get '/examples/:key' do
      Example.where(rspec_run: params['key']).to_json
    end

    post '/examples' do
      payload = JSON.parse(request.body.read)

      data = payload['examples'].map do |args|
        { rspec_run: args['rspec_run'], properties: args }
      end

      Example.create(data)
    end
  end
end
