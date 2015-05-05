require 'rubygems'
require 'bundler/setup'
require 'rack/ssl'
require 'sinatra/auth/github'

module Example
  class BadAuthentication < Sinatra::Base
    get '/unauthenticated' do
      status 403
      <<-EOS
      <h2>Unable to authenticate, sorry</h2>
      <p>#{env['warden'].message}</p>
      EOS
    end
  end

  class SimpleApp < Sinatra::Base
    #set views
    set :views, File.expand_path('../../views', __FILE__)

    enable :sessions
    enable :raise_errors
    disable :show_exceptions
    #enable :inline_templates

    set :github_options, {
      :scope => 'user',
      :secret => ENV['GITHUB_CLIENT_SECRET'] || 'test_client_secret',
      :client_id => ENV['GITHUB_CLIENT_ID'] || 'test_client_id'
    }
    register Sinatra::Auth::Github

    get '/' do
      erb :index
    end

    get '/profile' do
      authenticate!
      erb :profile
    end

    get '/login' do
      authenticate!
      redirect '/'
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end

  def self.app
    @app ||= Rack::Builder.new do
      run SimpleApp
    end
  end
end


