require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/content_for'
require 'sass'
require 'bootstrap-sass'
require 'sass/plugin/rack'
require 'compass-core'


Bundler.require

require './config/environments'

require_relative 'generators/SWSpeciesSelector'

require_relative 'ffgsw/talent_functions'

# Improves error messaging
configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

# Sass inclusion
Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:css_location] = './public/css'
use Sass::Plugin::Rack

require './models/Species'
require './models/Crawls'

get '/' do
  erb :frontpage
end

get '/talenttreetest' do
  @args_arr = pass_parsed_talent
  @svg_locs = gen_svg_paths(@args_arr[0].length, @args_arr[1].length)
  @sizing = pass_width_height
  erb :talent_trees
end

get '/crawls/make' do
  erb :makecrawl
end

post '/crawls/make' do
  new_crawl = Crawls.new
  new_crawl.name_verbose = "#{params[:crawlname]}"
  split_name = "#{params[:crawlname]}".downcase.split(/\s/)
  short_name = ""
  split_name.each_with_index do |val, index|
    short_name << val
    if index < split_name.length-1
      short_name << '_'
    end
  end
  new_crawl.name = short_name
  new_crawl.contents = "#{params[:contents]}"
  new_crawl.save
end

get '/crawls/view/all' do
  if params['offset'] 
    @offset = params['offset'].to_i
  else
    @offset = 0
  end
  @num_crawls = Crawls.count
  @crawls = Crawls.limit(10).offset(@offset)
  erb :allcrawls
end

get '/crawls/view/:crawlname' do
  if Crawls.exists?(:name => "#{params[:crawlname]}")
    the_crawl = the_crawl = Crawls.where(:name => "#{params[:crawlname]}").take
    content = the_crawl.contents
    @crawl_contents = content.split(/$/)
    @crawl_name = the_crawl.name_verbose
    erb :crawl
  else
    redirect to('/crawls/view/all')
  end
end

get '/generators/species-select' do
  erb :species_select
end

# Target for AJAX calls to select a species
get '/api/generators/species-select' do
  num_results = params[:num_species]
  STDERR.puts(params)
  restrict = {}
  required = {}
  STDERR.puts(params[:social_statuses].to_s)
  if params[:social_statuses] != ''
    if params[:social_statuses]['0']
      params[:social_statuses]['0'].each_index do |i|
        required[params[:social_statuses]['0'][i].to_sym] = true
      end
    end
    if params[:social_statuses]['1']
      params[:social_statuses]['1'].each_index do |i|
        restrict[params[:social_statuses]['1'][i].to_sym] = true
      end
      STDERR.puts(restrict)
    end
  end
  
  specials = [[:bio_type, :biology_type],
              [:body_structure, :bodily_structure],
              [:diet, :diet], 
              [:force_sensitivity, :force_sensitivity],
              [:lifespan, :lifespan]]
  extras = {}              
  specials.each do |i|
    case i[0]
    when :bio_type, :body_structure, :diet
      tmp = params[i[0]]
      parse_for_true(tmp)
      extras[i[1]] = tmp
    else
      extras[i[1]] = params[i[0]]
    end
  end
  gen = SWSpeciesSelector.new({
    :table => Species,
    :required => required,
    :forbidden => restrict,
    :coefficients => {},
    :rarity_weightings => [params[:human_prefs], params[:rarity_prefs]],
    :galactic_location => params[:galactic_location],
    :extra_handling => extras
  })
  @chosen = []
  for i in 0...num_results.to_i
    spec = gen.choose
    if spec
      @chosen << [spec.name, spec.wiki_link]
    else
      @chosen << ["No Results"]
    end
  end
  STDERR.puts @chosen.to_s
  content_type :json
  @chosen.to_json
end

# If possible, provide one restriction factor for the SQL query; others go in 
# an array to be handled later
def split_reqs(param)
  STDERR.puts("splitting " + param.to_s)
  arr = []
  restriction = nil
  # If true, required value; if false, restricted value
  restriction_type = false
  STDERR.puts(param.count(false).to_s + " falses")
  if param.count(false) > 0
    STDERR.puts(param.count(true).to_s + " trues")
    if param.count(true) == 1
      restriction = param[param.index(true)]
      restriction_type = true
    else
      restriction_type = false
      restriction = param.slice!(param.index(false))
      while param.include? false
        arr << param.slice!(param.index(false))
      end
    end
  end
  return [arr, restriction, restriction_type]
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