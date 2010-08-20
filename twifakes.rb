require 'rubygems'
require 'sinatra'
require 'yaml'
require 'twitter_oauth'
require 'sinatra/r18n'

set :default_locale, 'en'
set :translations,   './locales'

before do
  session[:locale] = params[:locale] || "en"
end

get "/" do
  erb :index
end

get "/connect" do
  client = TwitterOAuth::Client.new(:consumer_key => config_file['consumer_key'], :consumer_secret => config_file['consumer_secret'])
  request_token = client.request_token(:oauth_callback => config_file["oauth_callback_url"])
  redirect request_token.authorize_url
end

get "/oauth" do
  client = TwitterOAuth::Client.new(:consumer_key => config_file['consumer_key'], :consumer_secret => config_file['consumer_secret'])
  access_token = client.authorize(params[:request_token], params[:request_token_secret], :oauth_verifier => params[:oauth_verifier])
  client.update("I have #{(client.info["followers_count"].to_i/12).to_i} fake followers and you? http://twifake.heroku.com/") if client.authorized?
end

private
  def config_file
    YAML.load_file("config/twitter.yml")
  end

