require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/content_for'

Bundler.require

configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end
  
if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/development.db',
    :encoding => 'utf8'
  )
end

require './models/Species'

rarity_coefficients = {"Common" => 24.0, "Uncommon" => 12.0, "Rare" => 4.0, "Super Rare" => 2.0, "Near-Mythical" => 1.0}

get '/' do
  erb :frontpage
end

get '/generators/species-select' do
  erb :species_select
end

get '/api/generators/species-select' do
  content_type :json
  "Hutt".to_json
end

# rarity_factor is an integer, indicating how strongly weighting toward rarity should be a thing
# species_probabilities is the hash containing relative distribution of each species
# human_rarity is either "Ubiquitous" (40% flat), "Common" (Twi'lek rarity), or "None" (None)
def adjust_by_rarity(rarity_factor, species_probabilities, region, human_rarity)
  all_species = Species.find(:all)
  total = 0.0
  # Iterate through all the species
  all_species.each do |i|
    # Ignore this if it's humans
    unless i.name == "Human"
      home = i.home_region
      effective_rarity = i.rarities_by_region[home]
      # Multiply the probability of finding the species by the appropriate rarity coefficient for the region
      species_probabilities[i.name] *= rarity_coefficients[effective_rarity]**(rarity_factor/3.0) 
      # Keep track of the total weighting
      total += rarity_coefficients[effective_rarity]
    end
  end
  # Set human rarity to 40% after the fact
  if human_rarity == "Ubiquitous"
    species_probabilities["Human"] *= total*(2.0/3.0)
  # Set humans to Twi'lek rarity if that's the setting selected
  elsif human_rarity == "Common"
    species_probabilities["Human"] *= rarity_coefficients["Common"]**(rarity_factor/3.0)
  # Set humans to 0 rarity otherwise
  else
    species_probabilities["Human"] *= 0.0
  end
end