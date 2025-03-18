require 'rack'
require 'sequel'
require 'dotenv'
require_relative 'app'

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']

run WebChatApp
