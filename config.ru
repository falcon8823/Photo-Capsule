require 'sinatra'

set :environment, :production

require './capsule'
run Sinatra::Application
