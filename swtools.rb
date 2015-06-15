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

before do
  @rarity_coefficients = {"Common" => 192.0, "Uncommon" => 48.0, "Rare" => 16.0, "Super Rare" => 8.0, "Near-Mythical" => 1.0}
end

get '/' do
  erb :frontpage
end

get '/generators/species-select' do
  erb :species_select
end

# TODO: Figure out why occasionally it gives 'object object' to the browser
get '/api/generators/species-select' do
  if params[:human_prefs] == 0
    human_prefs = "None"
  elsif params[:human_prefs] == 1
    human_prefs = "Common"
  else
    human_prefs = "Ubiquitous"
  end
  rarity_weight = params[:rarity_prefs].to_i
  galactic_location = params[:galactic_location].to_s
  chosen = []
  all_species = Species.all
  for i in 0..params[:num_species].to_i
    initial_gen = species_basic_distribution(all_species)
    chosen << select_species({:human_prefs => human_prefs, :rarity_weighting => rarity_weight, :region => galactic_location}, initial_gen)
  end
  puts chosen.to_s
  content_type :json
  chosen.to_json
end

def select_species(preferences, initial_gen)
#  puts "Human prefs are " + preferences[:human_prefs].to_s
  species_probabilities = adjust_by_rarity(initial_gen[:species_records], preferences[:rarity_weighting], initial_gen[:species_probs], preferences[:region], preferences[:human_prefs])
  total = 0.0
  species_probabilities.each do |name, prob|
    total += prob
  end
  rng = Random.new.rand(total)
  last_name = ""
  temp = 0.0
  species_probabilities.each do |name, prob|
    if (temp > rng)
#      puts "Human Probability is " + species_probabilities["Human"].to_s + " out of " + total.to_s
#      puts "Twi'lek Probability is" + species_probabilities["Twi'lek"].to_s + " out of " + total.to_s
#      puts "Winner was " + last_name + " at " + species_probabilities[last_name].to_s + " out of " + total.to_s
      return last_name
    else
      last_name = name
      temp += prob
    end
  end
end

# Generates the basic distribution, with all species at equal probability
def species_basic_distribution(all_species)
  species_probabilities = {}
  all_species.each do |i|
    species_probabilities[i.name] = 1.0
  end
  return {:species_records => all_species, :species_probs => species_probabilities}
end

# rarity_factor is an integer, indicating how strongly weighting toward rarity should be a thing
# species_probabilities is the hash containing relative distribution of each species
# human_rarity is either "Ubiquitous" (40% flat), "Common" (Twi'lek rarity), or "None" (None)
def adjust_by_rarity(all_species, rarity_factor, species_probabilities, region, human_rarity)
#  puts "Human Rarity is" + human_rarity.to_s
  total = 0.0
  # Iterate through all the species
  all_species.each do |i|
    # Ignore this if it's humans
    unless i.name == "Human"
      home = i.home_region
      effective_rarity = i.rarities_by_region[home]
      # Multiply the probability of finding the species by the appropriate rarity coefficient for the region
      mult = @rarity_coefficients[effective_rarity]**(rarity_factor/3.0)
      species_probabilities[i.name] *= mult
      # Keep track of the total weighting
      total += @rarity_coefficients[effective_rarity]**(rarity_factor/3.0)
    end
  end
  # Set human rarity to 40% after the fact
  if human_rarity == "Ubiquitous"
#    puts "Multiplying human rarity by " + (total * 2.0/3.0).to_s + " of a possible " + total.to_s
    species_probabilities["Human"] *= total*(2.0/3.0)
  # Set humans to Twi'lek rarity if that's the setting selected
  elsif human_rarity == "Common"
    species_probabilities["Human"] *= @rarity_coefficients["Common"]**(rarity_factor/3.0)
  # Set humans to 0 rarity otherwise
  else
    species_probabilities["Human"] *= 0.0
  end
  return species_probabilities
end