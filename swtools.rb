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
  
require './models/Species'

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/development.db',
    :encoding => 'utf8'
  )
end

rarity_coefficients = {"Common" => 24.0, "Uncommon" => 12.0, "Rare" => 4.0, "Super Rare" => 2.0, "Near-Mythical" => 1.0}

get '/' do
  erb :frontpage
end

def adjust_by_rarity(coefficient, species_probabilities, region)
  all_species = Species.find(:all)
  total = 0.0
  all_species.each do |i|
    unless i.name == "Human"
      home = i.home_region
      effective_rarity = i.rarities_by_region[home]
      species_probabilities[i.name] *= rarity_coefficients[effective_rarity]
    end
  end
end