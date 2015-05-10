require 'rubygems'
require 'bundler/setup'
require 'rack/ssl'
require 'sinatra/auth/github'
require 'rest_client'
require 'json'

module Example
  class MainApp < Sinatra::Base

    CLIENT_ID = "3840d90d97d7f5b9fc15"
    CLIENT_SECRET = "5f0bf9755134e8f2a6f2091f7e101a514a649b4b"

    use Rack::Session::Pool, :cookie_only => false

    set :views, File.expand_path('../../views', __FILE__)
    set :public_folder, 'public'

    def authenticated?
      session[:access_token]
    end

    def list_repos
      repos = ['hanuman', 'minerva']
    end

    get '/' do
      if authenticated?
        user_info = JSON.parse(RestClient.get("https://api.github.com/user",
                                              {:params => {:access_token => session[:access_token]}}))
        session['user'] = user_info
      end
      erb :index, :locals => {:client_id => CLIENT_ID, :user => user_info}
    end

    get '/callback' do
      session_code = request.env['rack.request.query_hash']['code']

      result = RestClient.post('https://github.com/login/oauth/access_token',
                               {:client_id => CLIENT_ID,
                                :client_secret => CLIENT_SECRET,
                                :code => session_code},
                                :accept => :json)
      session[:access_token] = JSON.parse(result)['access_token']
      redirect '/';
    end

    post '/pullrequest' do
      if authenticated?
        repo_name = params[:repo]
        repos = JSON.parse(RestClient.get("https://api.github.com/repos/amedia/#{repo_name}/pulls",
                                             :Authorization => "token #{session[:access_token]}"))
        erb :pullrequest, :locals => {:repos => repos, :client_id => CLIENT_ID, :repo_name => repo_name}
      end
    end

    get '/pullrequest' do
      if !authenticated?
        redirect "https://github.com/login/oauth/authorize?scope=user:email,repo&client_id=#{CLIENT_ID}"
      end
      erb :pullrequest, :locals => {:client_id => CLIENT_ID, :repos => nil}
    end

    get '/logout' do
      session.clear
      redirect '/'
    end

  end

  def self.app
    @app ||= Rack::Builder.new do
      run MainApp
    end
  end
end


