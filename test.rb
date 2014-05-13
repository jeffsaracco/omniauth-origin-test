require 'sinatra'
require 'haml'
require 'omniauth'
require 'omniauth-twitter'
require 'pry'
require 'better_errors'
require 'binding_of_caller'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

configure do
  enable :sessions

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET']
  end
end

get '/' do
  haml :index
end

helpers do
  # define a current_user method, so we can be sure if an user is authenticated
  def current_user
    !session[:uid].nil?
  end

  def name
    session[:name]
  end
end

before do
  pass if request.path_info =~ /^\/auth\//

  redirect to('/auth/twitter?origin=%2Fauthed') unless current_user
end

get '/auth/twitter/callback' do
  session[:uid] = env['omniauth.auth']['uid']
  session[:name] = request.env["omniauth.auth"]["info"]["name"]

  redirect to(request.env['omniauth.origin'])
end

get '/auth/failure' do
  haml :failure
end

get '/' do
end

get '/authed' do
  haml :index
end
