require 'sinatra/base'
require 'sinatra/auth/github'

Dir.glob('./{controllers,helpers}/*.rb').each {|file| require file}

run Controller.app
