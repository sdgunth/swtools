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
  @rarity_coefficients = {"Ubiquitous" => 768.0, "Pervasive" => 384.0, "Common" => 192.0, "Uncommon" => 48.0, "Rare" => 16.0, "Super Rare" => 8.0, "Near-Mythical" => 1.0}
end

get '/' do
  erb :frontpage
end

get '/generators/species-select' do
  erb :species_select
end

# Target for AJAX calls to select a species
get '/api/generators/species-select' do
  rarity_weight = params[:rarity_prefs].to_i
  galactic_location = params[:galactic_location].to_s
  human_prefs = params[:human_prefs]
    puts human_prefs
    puts human_prefs.class
  @chosen = []
  @all_species = generate_species(params[:social_statuses])
  for i in 0...params[:num_species].to_i
    species_probs = species_basic_distribution
    @chosen << select_species({:human_prefs => human_prefs, :rarity_weighting => rarity_weight, :region => galactic_location, :species_probs => species_probs})
  end
  STDERR.puts @chosen.to_s
  content_type :json
  @chosen.to_json
end

# Generates species, ensuring restrictions are followed
def generate_species(social_status)
  parse_for_true(social_status["0"])
  parse_for_true(social_status["1"])
  # Parsing social status variables
  social_statuses = [:liked, :respected, :beloved, :enslaved, :denigrated, :feared, :hated, :neutral, :mysterious]
  is_social_freedom = social_status["0"]
  social_restriction_type = social_status["1"]

  # If there are no restrictions, return all the species
  if ((is_social_freedom.include? false) == false)
    return Species.all
  end
  
  # Leave only the restrictions to be used
  while is_social_freedom.include? true
    ind = is_social_freedom.index(true)
    social_statuses.delete_at(ind)
    social_restriction_type.delete_at(ind)
    is_social_freedom.delete_at(ind)
  end
  
  # Make the social restrictions hash
  args = ''
  social_hash = {}
  iterator = 'var_01'
  social_statuses.each_index do |i|
    if i > 0
      args << ' and '
    end
    args << social_statuses[i].to_s << ' = :' << iterator
    social_hash[iterator.to_sym] = social_restriction_type[i]
    iterator = iterator.next
  end
  
  return Species.where(args, social_hash)
end

def select_species(preferences)
  # If no species match the requirements, say so
  if @all_species.length == 0
    return ["No Species Matching Criteria", ""]
  end
  species_probabilities = adjust_by_rarity(preferences[:rarity_weighting], preferences[:species_probs], preferences[:region], preferences[:human_prefs])
  # Sums the various probabilities, giving the total weight
  total = 0.0
  species_probabilities.each do |name, prob|
    total += prob
  end
  
  # Generate random number within the total
  rand_num = Random.new.rand(total)
  subtotal = 0.0
  # Go through the list
  for i in 0...species_probabilities.length do
    range = subtotal...(subtotal + species_probabilities.values[i])
    if range.cover? rand_num
      return [species_probabilities.keys[i], @all_species.where(:name => species_probabilities.keys[i]).take().wiki_link]
    end
    subtotal += species_probabilities.values[i]  
  end
  
  # If we got here, something went wrong and I want it logged
  tmp = ""
  last = "0"
  for i in 0...species_probabilities.length do
    tmp << last << " to " << (last.to_f + species_probabilities.values[i]).to_s << ": " << species_probabilities.keys[i] << "\n"
    last = (last.to_f + species_probabilities.values[i]).to_s
  end
  STDERR.puts tmp
  STDERR.puts "Random number was " + rand_num.to_s
end

# Generates the basic distribution, with all species at equal probability
def species_basic_distribution
  species_probabilities = {}
  @all_species.each do |i|
    species_probabilities[i.name] = 1.0
  end
  return species_probabilities
end

# rarity_factor is an integer, indicating how strongly weighting toward rarity should be a thing
# species_probabilities is the hash containing relative distribution of each species
# human_rarity is either '2' (40% flat), '1' (Twi'lek rarity), or '0' (None)
def adjust_by_rarity(rarity_factor, species_probabilities, region, human_rarity)
#  puts "Human Rarity is" + human_rarity.to_s
  total = 0.0
  # Iterate through all the species
  @all_species.each do |i|
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
  # Don't adjust human rarity if humans can't be chosen
  unless species_probabilities["Human"] == nil
    # Sets human rarity to 40% of the total weighting
    if human_rarity == '2'
      species_probabilities["Human"] *= total*(2.0/3.0)
    # Set humans to Twi'lek rarity if that's the setting selected
    elsif human_rarity == '1'
      species_probabilities["Human"] *= @rarity_coefficients["Ubiquitous"]**(rarity_factor/3.0)
    # Set humans to 0 rarity otherwise
    else
      species_probabilities["Human"] *= 0.0
    end
  end
  return species_probabilities
end

# Converts string values of 'true' and 'True' into boolean 'true' and same for falses
# WARNING: Doesn't work on nested arrays or hashes
def parse_for_true(args)
  # If it's a hash, recurse
  if args.class == Hash
    hash_keys = args.keys
    for i in 0...args.length
      args[hash_keys[i]] = parse_for_true(args[hash_keys[i]])
    end
  # If it's an array, recurse
  elsif args.class == Array
    for i in 0...args.length
      args[i] = parse_for_true(args[i])
    end
  # If it is a single object, evaluate for falsiness
  else
    if args == "true" || args == "True"
      return true
    elsif args == "false" || args == "False"
      return false
    else
      return args
    end
  end
end