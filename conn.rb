require "sinatra/base"
require "redd"
require "yaml"
class Settings
  KEYS = YAML.load_file('keys.yml')
end

class ConnectToReddit < Sinatra::Base
  configure do
    enable :sessions

    # If you're on Rails, you can replace the fixed url with a named one (e.g. redirect_url).
    set :client, Redd::Client::OAuth2.new("57AkCvRjcSyBfg", Settings::KEYS['OAUTH_SECRET'], "http://localhost:9292/auth/reddit/redirect")
  end

  get "/auth/reddit" do
    # Make use of the state!
    # SecureRandom, which is included in Ruby, helps create a url-safe random string.
    state = SecureRandom.urlsafe_base64
    session[:state] = state
    redirect settings.client.auth_url(["identity","mysubreddits","read","history"], :permanent, state)
  end

  get "/auth/reddit/redirect" do
    raise "Your state doesn't match!" unless session[:state] == params[:state]

    # access is a Redd::OAuth2Access object.
    access = settings.client.request_access(params[:code])
    me = settings.client.with_access(access) { |client| client.me }
    puts access.to_json
    redirect to("/success")
  end

  get '/success' do
    
  end
end

