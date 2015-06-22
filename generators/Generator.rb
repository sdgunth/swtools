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
  #           (Optional)
  # :coefficients - A hash of arrays, carrying the probability weightings of given
  #           column values. array[0] is the comparator (==, >, >=, <=, <, .., ...)
  #           as a string, array[1] is the desired value (in the case of a range
  #           comparator, it is instead an array with [range_bottm, range_top]), 
  #           array[2] is the probability multiplier.
  #           Example: {"height" => ['==', 64, 2.0], "weight" => ['>=', 130, 5.0]}.
  #           (Optional)
  def initialize(args)
    @table = args[:table]
    @coefficients = args[:coefficients]
    @required = args[:required]
    @forbidden = args[:forbidden]
      
    enforce_specified_values
    generate_rarities
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
  
  # Internal: This method generates the list of objects to select from and
  # modifies their probabilities according to the definition of @coefficients
  # and combine_multipliers()
  def generate_rarities
    @probabilities = {}
    @list.each do |val|
      @probabilities[val.id] = 1.0 
      combine_multipliers(val)
    end
  end
  
  # Public: This method generates the random number, selects the appropriate
  # result, and returns it as an ActiveRecord relation. If overriding initialize,
  # make sure to run enforce_specified_values and generate_rarities before
  # calling this method.
  def choose
    ranges = []
    subtotal = 0.0
    @probabilities.each do |key, value|
      ranges << subtotal...(subtotal + value)
      subtotal += value
    end
    rand_num = Random.new.rand(ranges[-1].end)
    ranges.each do |i|
      if i.cover? rand_num
        return @list.where(id: i.id)
      end
    end
  end
  
  # Internal: This method takes a given row and runs it through all the relevant
  # multipliers provided by @coefficients. This should be overridden if the
  # generator requires special treatment for certain values, or if the value
  # being stored in the database is a hash or array (and thus requires further
  # processing to compare)
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
        matches = compare_values(val[0], row[key])
      end
      if matches
        @probabilities[row.id] *= val[2]
      end
    end
  end
  
  # Internal: This is the method used to compare values by this function. It
  # currently supports only Floats, Fixnums, and easily-coerce-able Strings 
  # (decimal strings)
  # 
  # Most Generator extensions will want to override this with their own
  # comparison functions. Overrides of this class MUST support all comparators
  # used in @coefficients.]
  def compare_values(comparator, arg, *other_args)
    supported_comparators = ['<', :<, '<=', :<=, '==', :==, '>=', :>=, '>', :>]
    vals = [nil, nil]
    args = [arg]
    # Adds additional arguments if there are any
    if other_args.length > 0
      args << other_args[0]
    end
    # Checks both arguments, setting vals as needed
    args.each_index do |i|
      case args[i].class
      when Fixnum, Float
        vals[i] == args[i]
      when String
        unless args[i].to_f == 0.0 && args[i] != '0' && args[i] != '0.0'
          vals[i] == args[i]
        end
      end
    end
    # Vals will only include a nil if the inputs were not a mixture of float, fixnum, and convertable integer
    unless vals.include? nil
      # If it's one of the common set of comparators, run the operation directly
      if supported_comparators.include? comparator
        return arg1.send(comparator, arg2)
      # If it's a range, check inclusion
      elsif comparator.class == Range
        return (comparator.include? arg) 
      end
    end
    # If we got to here, there was a problem - raise an exception
    raise ('Tried to compare ' + args.to_s + ' to ' +  + ' - Invalid comparison')
  end
end