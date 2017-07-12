require 'sinatra'
require 'bundler'
require 'rake'
require 'sinatra/activerecord'
require './models/model'        #Model class
require 'dotenv/load'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'haml'

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

  get '/' do
    erb :index
    session["value"] ||= "Hello world!"
    "The cookie you've created contains the value: #{session["value"]}"
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
    @models = Model.all
    erb :models
  end

  get '/auth/:provider/callback' do
    erb "<h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
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

