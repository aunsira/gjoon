require 'sinatra/base'
require 'sinatra/auth/github'

Dir.glob('./{module}/*.rb').each {|file| require file}

run Example.app
