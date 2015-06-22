# Public: This is the basic class for a generator using ActiveRecord. Ideally, 
# everything can just extend this, with their own methods to massage their data 
# to fit it.
class Generator
  
  # Public: Initialize a generator
  #
  # :table - The class name of the table being pulled (e.g. Species or Clients).
  #           Absolutely required. The class will break without it.
  # :required - A hash of the specific required column values in the pulled rows.
  #           Example: {"city" => "Seattle", "currently_subscribed" => true}. 
  #           (Optional)
  # :restricted - a hash of the specific disallowed column values in the pulled rows.
  #           Example: {"last_name" => "Smith"}
  # :coefficients - A hash of arrays, carrying the probability weightings of given
  #           column values. array[0] is the comparator (==, >, >=, <=, <, .., ...)
  #           as a string, array[1] is the desired value (in the case of a range
  #           comparator, it is instead an array with [range_bottm, range_top]), 
  #           array[2] is the probability multiplier.
  #           Example: {"height" => ['==', 64, 2.0], "weight" => ['>=', 130, 5.0]}.
  #           (Optional)
  def initialize(args)
    @args = args
    @table = args[:table]
    @coefficients = args[:coefficients]
    @required = args[:required]
    @forbidden = args[:forbidden]
  end

  
  # Internal: This method pulls the records from the table that have certain 
  # SPECIFIC required  or rejected values. For instance, if the table is of 
  # clients, and I want to pull all the clients who live in Seattle, are 
  # currently subscribed, have been subscribers for more than six months, and
  # are not named 'Dave', this method would return the clients whose 'city' 
  # column says 'Seattle', whose 'currently_subscribed' column says 'true', 
  # and whose name column does not say 'Dave'
  def enforce_specified_values
    args = ''
    sym_hash = {}
    iterator = 'var_01'
    # Forms an appropriate ActiveRecord query - for the above example, it would
    # call Clients.where('city = :var_01 and subscribed = :var_02', 
    #                    {:var_01 => 'Seattle', :var_02 => true})
    @required.keys.each do |key, value|
      if iterator > 'var_01'
        args << ' and '
      end
      args << key << ' = :' << iterator
      sym_hash[iterator.to_sym] = value
      iterator = iterator.next
    end
    
    @forbidden.keys.each do |key, value|
      if iterator > 'var_01'
        args << ' and '
      end
      args << key << ' != :' << iterator
      sym_hash[iterator.to_sym] = value
      iterator = iterator.next
    end
    
    @list = @table.where(args, sym_hash)
  end
end