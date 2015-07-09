# Public: This is the subclass of Generator for selecting a species from the list
# of Star Wars species. 
#
# It assumes species are held in a table called Species. 
class SWSpeciesSelector < Generator
  # Make sure to sort comparable traits from 'smallest' to 'largest'
  @supported_comparable_traits = {
    :sizes => ["Tiny", "Small", "Average", "Large", "Huge"],
    :lifespan => ["Short", "Normal", "Long", "Very Long", "Indefinite"]
  }
  
  @rarity_coefficients = {"Ubiquitous" => 768.0, "Pervasive" => 384.0, "Common" => 192.0, "Uncommon" => 48.0, "Rare" => 16.0, "Super Rare" => 8.0, "Near-Mythical" => 1.0}
  
  # TODO: CUSTOMIZE THIS TO BE SW-SPECIES-SELECT STUFF
  # Public: Initialize a star wars species selector
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
  # 
  def initialize(args)
    if args[:table] == nil
      raise ":table is nil"
      break
    end
    if ActiveRecord::Base.connection.table_exists? args[:table]
      @table = args[:table]
    else
      raise "No table by the name #{args[:table]}" 
    end
    @table = args[:table]
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
      
    enforce_specified_values
    generate_rarities
  end
  
  # Internal: This method takes a given row and runs it through all the relevant
  # multipliers provided by @coefficients. The default has been overwritten to
  # allow galactic location support
  #
  # row - An ActiveRecord relation. If another object is desired, method must be
  # overwritten.
  def combine_multipliers(row)
    @coefficients.each do |key, val|
      if r
        
      else
        matches = nil
        if val[0] == '..'
          matches = compare_values(val[1][0]..val[1][1], row[key])
        elsif val[0] == '...'  
          matches = compare_values(val[1][0]...val[1][1], row[key])
        else
          matches = compare_values(val[0], row[key])
        end
        if matches
          @probabilities[row.id] *= val[2]
        end
      end
    end
  end
end