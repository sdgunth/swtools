# Public: This is the subclass of Generator for selecting a species from the list
# of Star Wars species. 
#
# It assumes species are held in a table called Species. 
class SWSpeciesSelector < Generator
  # Make sure to sort comparable traits from 'smallest' to 'largest'
  @supported_comparable_traits = {
    :sizes => ["Tiny", "Small", "Average", "Large", "Huge"],
    :lifespan => ["Short", "Normal", "Long", "Very Long", "Indefinite"],
  }
  
  # Public: Initialize a star wars species selector
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
  #           Example: {"height" => ['==', 64, 2.0], "weight" => ['>=', 130, 5.0]}.
  #           (Optional)
  # 
  #           For SW Species Select purposes, it will contain size, lifespan, and
  #           gender ratio comparators, setting invalid ones to 0.0
  # :rarity_weighting - The float version of the value selected for rarity weighting
  #           via slider - 0.0, 1.0, 2.0, 3.0, 4.0, or 5.0
  # :force_sensitivity_bias - The String value of the desired force sensitivity
  #           bias. Either "Bias Towards Low", "No Bias", or "Bias Towards High"
  def initialize(args)
    if args[:table] == nil
      raise ":table is nil"
      break
    end
    if ActiveRecord::Base.connection.table_exists? Species
      @table = Species
    else
      raise "No Species table" 
    end
    @coefficients = {}
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
      
    enforce_specified_values
    generate_rarities
    gen_coefficients(args[:rarity_weighting], args[:force_sensitivity_bias], args[:human_prefs])
    apply_scaling_rarities
  end
  
  def gen_coefficients(rarity_weighting, force_sensitivity_bias, human_prefs)
    # Apply the multiplier to the rarity coefficients
    @rarity_coefficients = {"Ubiquitous" => 768.0, "Pervasive" => 384.0, "Common" => 192.0, "Uncommon" => 48.0, "Rare" => 16.0, "Super Rare" => 8.0, "Near-Mythical" => 1.0}
    @rarity_coefficients.each do |key, val|
      val = val**(rarity_weighting/3.0)
    end
    
    @force_coefficients = {"Nonexistent" => 1.0, "Low" => 1.0, "Normal" => 1.0, "High" => 1.0, "Universal" => 1.0}
    case force_sensitivity_bias
    # Sets the coefficients to 9.0, 7.0, 5.0, 3.0, 1.0 - 2/3 "Nonexistent" and "Low"
    when "Bias Towards Low"
      mult = [9, 7, 5, 3, 1]
      ind = 0
    when "Bias Towards High"
      mult = [1, 3, 5, 7, 9]
      ind = 0
    end
    @force_coefficients.each do |key, val|
      val = val * mult[ind]
      ind += 1
    end
    @human_prefs = human_prefs
  end
  
  def apply_scaling_coefficients
    @list.each do |species|
      
    end
  end
end