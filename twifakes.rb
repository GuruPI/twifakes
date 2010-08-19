require 'rubygems'
require 'sinatra'
require 'yaml'
require 'twitter_oauth'

get "/" do
  render :index
end

get "/connect" do
  client = TwitterOAuth::Client.new(:consumer_key => config_file['consumer_key'], :consumer_secret => config_file['consumer_secret'])
  request_token = client.request_token(:oauth_callback => config_file["oauth_callback_url"])
  redirect request_token.authorize_url
end

get "/oauth" do
  client = TwitterOAuth::Client.new(:consumer_key => config_file['consumer_key'], :consumer_secret => config_file['consumer_secret'])
  access_token = client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => params[:oauth_verifier])

  if client.authorized?
    client.update("Juntos com o Sílvio. É dessa forma que você e eu iniciaremos a renovação do Piauí. Cadastre-se em http://bit.ly/jsilvio")
  end
end

private
  def config_file
    YAML.load_file("config/twitter.yml")
  end

