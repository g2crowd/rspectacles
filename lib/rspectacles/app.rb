require 'rubygems'
require 'sinatra/base'
require 'json'
require 'sinatra/activerecord'
require 'rspectacles/config.rb'
require 'rspectacles/app/models/example'
require 'rspectacles/app/models/run'
require 'puma'

module RSpectacles
  class App < Sinatra::Base
    require 'rspectacles/app/helpers'
    register Sinatra::ActiveRecordExtension

    set :database_file, 'config/database.yml'

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
    get '/' do
      @runs = Run.all.limit(25).order(rspec_run: :desc)
      erb :runs
    end

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

      run = Run.where(rspec_run: payload['examples'].first['rspec_run']).first_or_create
      data = payload['examples'].map do |args|
        { rspec_run: args['rspec_run'], duration: args['duration'].to_f, properties: args }
      end

      examples = Example.create(data)

      { errors: examples.count { |i| !i.persisted? } }.to_json
    end
  end
end
