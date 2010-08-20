require 'rubygems'
require 'sinatra'
require 'yaml'
require 'twitter_oauth'
require 'sinatra/r18n'

set :default_locale, 'en'
set :translations,   './locales'

before do
  session[:locale] = params[:locale] unless params[:locale].nil?
  set :locale, session[:locale]
end

configure do
  enable :sessions
end

get "/" do
  erb :index
end

get "/connect" do
  client = TwitterOAuth::Client.new(:consumer_key => ENV["CONSUMER_KEY"], :consumer_secret => ENV["CONSUMER_SECRET"])
  request_token = client.request_token(:oauth_callback => config_file["oauth_callback_url"])
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get "/oauth" do
  session[:oauth_verifier] = params[:oauth_verifier]
  erb :show
end

get "/tweet" do
  client = TwitterOAuth::Client.new(:consumer_key => ENV["CONSUMER_KEY"], :consumer_secret => ENV["CONSUMER_SECRET"])
  session[:access_token] = client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => session[:oauth_verifier])
  @fakes = (client.info["followers_count"].to_i/12).to_i
  client.update("I have #{(@fakes).to_i} fake followers, and you? http://twifakes.heroku.com/ #Twifakes") if client.authorized?
  redirect "/?s=ok"
end