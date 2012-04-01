require 'sinatra'

set :environment, :production

require './pictshare'
run Sinatra::Application
