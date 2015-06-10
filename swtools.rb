require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/content_for'

configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

#  TODO: Enable once databases are implemented 
#  
#if ENV['DATABASE_URL']
#  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
#else
#  ActiveRecord::Base.establish_connection(
#    :adapter => 'sqlite3',
#    :database => 'db/development.db',
#    :encoding => 'utf8'
#  )
#end

get '/' do
  erb :frontpage
end