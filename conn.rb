require "sinatra/base"
require "redd"

class ConnectToReddit < Sinatra::Base
  configure do
    enable :sessions

    # If you're on Rails, you can replace the fixed url with a named one (e.g. redirect_url).
    set :client, Redd::Client::OAuth2.new("sa_xTDcJ3dWz0w", "very-sensitive-secret", "http://localhost:8080/auth/reddit/redirect")
  end

  get "/auth/reddit" do
    # Make use of the state!
    # SecureRandom, which is included in Ruby, helps create a url-safe random string.
    state = SecureRandom.urlsafe_base64
    session[:state] = state
    redirect settings.client.auth_url(["identity"], :temporary, state)
  end

  get "/auth/reddit/redirect" do
    raise "Your state doesn't match!" unless session[:state] == params[:state]

    # access is a Redd::OAuth2Access object.
    access = settings.client.request_access(params[:code])
    me = settings.client.with_access(access) { |client| client.me }

    # Now use the Redd::Object::User object to create a user, maybe assign some
    # sort of token to remember their session.
    redirect to("/success")
  end
end