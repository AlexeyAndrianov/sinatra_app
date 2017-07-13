require 'sinatra'
require 'bundler'
require 'rake'
require 'sinatra/activerecord'
require './models/model'
require './models/user'        #Model class
require 'dotenv/load'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'jwt'
require 'pry'

if ENV['CLIENT_ID'] && ENV['CLIENT_SECRET']
  CLIENT_ID = ENV['CLIENT_ID']
  CLIENT_SECRET = ENV['CLIENT_SECRET']
else
  puts "Sorry, there was no tokens!"
end

enable :sessions

class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :github, CLIENT_ID,CLIENT_SECRET
    #provider :att, 'client_id', 'client_secret', :callback_url => (ENV['BASE_DOMAIN']

  end

  def private_session
    return erb :index unless token = session['user']
    #@data = JWT.decode token, 'password', true, { :algorithm => 'HS256' }
    #erb "<pre>#{@data[0]["data"]}</pre>"
    #return  unless data[0]["data"]
  end

  get '/' do
    #@user = User.all #show users
    erb :index
  end

  post '/submit' do
    @model = Model.new(params[:model])
    if @model.save
      redirect '/models'
    else
      "Sorry, there was an error!"
    end
  end

  get '/models' do
    #binding.pry;
    private_session
    @models = Model.all
    erb :models
  end

  get '/users' do
    #binding.pry;
    private_session
    @users = User.all
    erb :users
  end

  get '/privateurl' do
    private_session
  end

  get '/auth/:provider/callback' do
    #@user = User.new(params[:user])
    #if @user.save
    #  redirect '/users'
    #else
    #  "Sorry, there was an error!"
    #end
    private_session
    @user_name = request.env['omniauth.auth'][:info][:name]
    @user_id = request.env['omniauth.auth'][:uid]

    payload = { data: @user_id }
    #rsa_private = OpenSSL::PKey::RSA.generate 2048
    #rsa_public = rsa_private.public_key
    encr_user_id = JWT.encode payload, 'password', 'HS256'

    session["user"] = encr_user_id

    #decoded_token = JWT.decode token, rsa_public, true, { :algorithm => 'RS256' }
    #<pre>#{JSON.pretty_generate(request.env['omniauth.auth'][:uid])}</pre>

    erb "<h1>Hello, #{@user_name}. Your encrypted id is #{encr_user_id}</h1>"
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end

  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
         <a href='/logout'>Logout</a>"
  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

end

SinatraApp.run! if __FILE__ == $0

__END__

