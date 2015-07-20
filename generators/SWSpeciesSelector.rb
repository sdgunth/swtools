require_relative 'Generator'
require 'bundler/setup'

Bundler.require

# Public: This is the subclass of Generator for selecting a species from the list
# of Star Wars species. It requires ActiveRecord.
class SWSpeciesSelector < Generator
  # Public: Initialize a star wars species selector
  # TODO: Finish implementing things
  #
  # :table - The class name of the table being pulled (e.g. Species or Clients).
  #           Absolutely required. The class will break without it.
  # :required - A hash of the specific required column values in the pulled rows.
  #           Example: {"city" => "Seattle", "currently_subscribed" => true}. 
  #           (Optional)
  # :restricted - a hash of the specific disallowed column values in the pulled rows.
  #           Example: {"last_name" => "Smith"} 
  #           (Optional)
  # :coefficients - A hash of arrays, carrying the probability weightings of given
  #           column values. array[0] is the comparator (==, >, >=, <=, <, .., ...)
  #           as a string, array[1] is the desired value (in the case of a range
  #           comparator, it is instead an array with [range_bottm, range_top]), 
  #           array[2] is the probability multiplier.
  #             
  #           Example: {"height" => ['==', 64, 2.0], "weight" => ['>=', 130, 5.0]}.
  #           (Optional)
  # :galactic_location - A string, carrying the galactic location of where the gen
  #           is being performed. 
  #    
  #           Example: "Deep Core"
  # :rarity_weightings - An array, carrying the various rarity weighting data needed
  #           for calculations. Indexes are organized as follows:
  #           [0] = human rarity setting, either 0 (no humans), 1 (twi'lek rarity),
  #                 or 2 (40% humans)
  #           [1] = rarity weighting slider - default rarity weightings are raised
  #                 to the power of this number over 3
  # :social_statuses - An array of arrays, the first one containing stringified
  #           symbol names of required social statuses, the second containing
  #           forbidden social statuses
  # :extras - All the weird funky things that SWSpeciesSelector needs to parse that
  #           need handling sufficiently different from the core Generator logic
  #           that they need to be parsed differently 
  def initialize(args)
    STDERR.puts(args.to_s)
    @supported_comparable_traits = {
      :sizes => ["Tiny", "Small", "Average", "Large", "Huge"],
      :lifespan => ["Short", "Normal", "Long", "Very Long", "Indefinite"]
    }
    
    @rarity_coefficients = {"Ubiquitous" => 768.0, "Pervasive" => 384.0, 
      "Common" => 192.0, "Uncommon" => 48.0, "Rare" => 16.0, "Super Rare" => 8.0, 
      "Near-Mythical" => 1.0}
    if args[:table] == nil
      raise ":table is nil"
    else
      @table = args[:table]
    end
    if args[:coefficients] == nil
      @coefficients = args[:coefficients]
    else
      @coefficients = {}
    end
    if args[:required] == nil
      @required = {}
    else
      @required = args[:required]
    end
    if args[:forbidden] == nil
      @forbidden = {}
    else
      @forbidden = args[:forbidden]
    end
    @extras = {:true_false_arr => [],
               :complex_arr => []}
    tfkeys = [:biology_type, :bodily_structure, :diet]
    args[:extra_handling].each do |key, val|
      if tfkeys.include? key
        @extras[:true_false_arr] << {key => val}
      else
        @extras[:complex_arr] << {key  => val}
      end
    end
    @galactic_location = args[:galactic_location]
    @rarity_vals = args[:rarity_weightings]
      
      
    STDERR.puts(@forbidden.to_s)
    STDERR.puts(@required.to_s)
    enforce_specified_values
    generate_rarities
    if @rarity_vals[0].to_i == 2 
      handle_humans
    end
    STDERR.puts("Calling handle_specials")
    handle_specials
  end
  
  # Internal: This method takes a given row and runs it through all the relevant
  # multipliers provided by @coefficients. The default has been overwritten to
  # allow galactic location support as well as human rarity things
  #
  # row - An ActiveRecord relation. If another object is desired, method must be
  # overwritten.
  def combine_multipliers(row)
    @coefficients.each do |key, val|
      matches = nil
      if val[0] == '..'
        matches = compare_values(val[1][0]..val[1][1], row[key])
      elsif val[0] == '...'  
        matches = compare_values(val[1][0]...val[1][1], row[key])
      else
        matches = compare_values(val[0], row[key], val[1])
      end
      if matches
          @probabilities[row.id] *= val[2]
      end      
    end
    if ((row.name == "Human") && (@rarity_vals[0].to_i < 2))
      # If there are supposed to be no humans
      if @rarity_vals[0] == '0'
        @probabilities[row.id] = 0.0
      # If they're as rare as twi'leks
      else
        @probabilities[row.id] *= (768.0**(@rarity_vals[1].to_f/3.0))
      end
    else
      # General rarity multipliers
      @probabilities[row.id] *= 
        (@rarity_coefficients[row.rarities_by_region[@galactic_location]]**
        (@rarity_vals[1].to_f/3.0))
    end
  end
  
  # Internal: This method sets humans to 40% of the summed probability
  # (including the new human probability). 
  #
  # Example: Probability sum without humans is 45.0, this sets human probability
  # to 45.0*(2.0/3.0) = 30.0. 30.0/(45.0 + 30.0) = 0.4, or 40%.
  def handle_humans
    human_id = @list.where(name: 'Human').take
    if human_id
      human_id = human_id.id
      sum = 0.0
      @probabilities.each do |key, val|
        unless key == human_id
          sum += val
        end
      end
      @probabilities[human_id] = sum*(2.0/3.0)
    end
  end
  
  # Internal: This method handles all the weird special values that can be
  # selected to weight or restrict particular results from the web app
  def handle_specials
    # The corresponding vals for the true-false arrays
    translated_vals = {
      :biology_type => ["Mammal", "Insect", "Reptile", "Amphibian", "Exotic"],
      :bodily_structure => ["Near-Human", "Bipedal", "Quadripedal", "Hexapedal", 
                            "Insectoid", "Soft Invertebrate", "Amorphous"],
      :diet => ["Herbivore", "Omnivore", "Carnivore", "Exotic"]
    }
    required_vals = {}
    restricted_vals = {}
    # Handles all the true-false arrays
    @extras[:true_false_arr].each do |i|
      tmp_arr = []
      vals_arr = i.values[0]
      curr_key = i.keys[0]
      # If nothing is disallowed, there are no restrictions
      if vals_arr.include? false
        # If there's only one true value, and any false values, we can require
        # that value specifically
        if vals_arr.count(true) == 1
          required_vals[i.keys[0]] = 
          translated_vals[curr_key][vals_arr.index(true)]
          # If there are multiple true values, we have to settle for removing all the false values
        else
          for i in 0...vals_arr.length
            if !vals_arr[i]
              tmp_arr << translated_vals[curr_key][i]
            end
          end
          restricted_vals[curr_key] = tmp_arr
        end
      end
    end
    STDERR.puts("Required: " + required_vals.to_s + "\n Restricted: " + restricted_vals.to_s)
    # Apply the probability changes
    @probabilities.each do |prob_key, prob_val|
      # Take the row being operated on
      row = @list.where(id: prob_key).take
      required_vals.each do |key, val|
        if prob_val > 0.0
          # If it's not the required value, make the probability 0
          if ((row[key] != val) && (prob_val > 0.0))
            @probabilities[prob_key] = 0.0
          end
        end
      end
      # Apply the restricted values to the row
      restricted_vals.each do |key, val|
        if prob_val > 0.0
          val.each do |i|
            # If the row has the restricted value for the key
            if ((row[key] == i) && (prob_val > 0.0))
              # Remove its chance of coming up
              @probabilities[prob_key] = 0.0
            end
          end
        end
      end
    end
    probs_cleanup
  end
  
  # Internal: Removes all the 0-probability results from the probabilities array
  def probs_cleanup
    for i in 0...@probabilities.count
      if @probabilities.values[i] == 0.0
        @probabilities.delete(@probabilities.keys[i])
      end
    end
  end
end