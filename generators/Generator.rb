# Public: This is the basic class for a generator using ActiveRecord. Ideally, 
# everything can just extend this, with their own methods to massage their data 
# to fit it.
class Generator
  
  # Public: Initialize a generator
  #
  # :table - The class name of the table being pulled (e.g. Species or Clients).
  #           Absolutely required. The class will break without it.
  #
  # :required - A hash of the specific required column values in the pulled rows.
  #           Example: {"city" => "Seattle", "currently_subscribed" => true}. 
  #           (Optional)
  #
  # :restricted - a hash of the specific disallowed column values in the pulled rows.
  #           Example: {"last_name" => "Smith"} 
  #           (Optional)
  #
  # :coefficients - A hash of arrays, carrying the probability weightings of given
  #           column values. array[0] is the comparator (==, >, >=, <=, <, .., ...)
  #           as a string, array[1] is the desired value (in the case of a range
  #           comparator, it is instead an array with [range_bottm, range_top]), 
  #           array[2] is the probability multiplier.           
  #           Example: {"height" => ['==', 64, 2.0], "weight" => ['>=', 130, 5.0]}.
  #           (Optional)
  #
  # :supported_comparables - A hash of arrays, carrying the database name of the
  #           trait to be compared and a hash of its possible values, ordered 
  #           smallest to largest.
  #           Example: {"Height" => ["Short", "Average", "Tall"]}
  #           (Optional)
  #
  def initialize(args)
    if args[:table] == nil
      raise ":table is nil"
    else      
      @table = args[:table]
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
    if args[:supported_comparables] == nil
      @supported_comparable_traits = {}
    else
      @supported_comparable_traits = args[:supported_comparabls]
    end
      
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
    @required.each do |key, value|
      if iterator > 'var_01'
        args << ' and '
      end
      args << "#{key} = :#{iterator}"
      STDERR.puts(value)
      sym_hash[iterator.to_sym] = value
      iterator = iterator.next
    end
    
    @forbidden.each do |key, value|
      if iterator > 'var_01'
        args << ' and '
      end
      args << "#{key} != :#{iterator}"
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
    ids = []
    subtotal = 0.0
    @probabilities.each do |key, value|
      ranges << (subtotal...(subtotal + value))
      ids << key
      subtotal += value
    end
    unless ranges.length == 0
      rand_num = Random.new.rand(ranges[ranges.length-1].end)
      ranges.each do |i|
        if i.cover? rand_num
          ind = ranges.find_index(i)
          result = @list.where(id: ids[ind]).take
          return result
        end
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
        matches = compare_values(val[0], row[key], val[1])
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
  # used in @coefficients.
  def compare_values(comparator, arg, *other_args)
    # If being given a range
    if comparator.class == Range
      trait = nil
      # Iterate through supported comparable traits, figuring out which one is
      # being looked into
      @supported_comparable_traits.each do |key, val|
        val.include?(arg) ? (trait = key) : nil
      end
      # Make sure that the arg and the comparator are from the SAME trait
      if ((@supported_comparable_traits[trait].include? comparator.begin) && 
          (@supported_comparable_traits[trait].include? comparator.end))
        # Make sure the range conversion is the right level of exclusivity
        if comparator.exlude_end?
          converted_range = get_int_val(comparator.begin)...get_int_val(comparator.end)
        else
          converted_range = get_int_val(comparator.begin)..get_int_val(comparator.end)
        end
        return (converted_range.cover? @supported_comparable_traits[trait].index(arg))
      else
        raise("#{arg} is not between #{comparator.begin} and #{comparator.end}")
      end
    elsif arg.boolean?
      if other_args[0].boolean?
        return arg.send(comparator, other_args[0])
      else
        raise("Tried to compare a boolean to a not-boolean")
      end
    elsif arg.class == String
      if arg.to_s
      # Otherwise, check and make sure that the args are from the same trait
      elsif (@supported_comparable_traits[trait].include? arg &&
          @supported_comparable_traits[trait].include?(other_args[0]))
          # Compare their indexes
         return get_int_val(arg).send(comparator, get_int_val(other_args[0]))
      else
        raise "Error: #{arg} and #{other_args[0]} are not both found in one category"
      end
    end
    raise("Something went wrong! Attempted to evaluate #{arg} (#{arg.class})" << 
          "#{comparator} (#{comparator.class}) #{other_args[0]} (#{other_args[0].class})")
  end
    
    # Internal: Takes a String value and finds its numerical equivalent (array index)
    # from @supported_comparable_traits
  def get_int_val(string)
    correct_key = nil
    @supported_comparable_traits.each do |key, val|
      if val.include? string
        correct_key = key
      end
    end
    if correct_key
      return @supported_comparable_traits[key].find_index(string)
    else
      raise "Error: #{string} is not recognized as a comparable trait"
    end
  end

  # Internal: Monkey patches object to check if a value is boolean
  class Object
    def boolean?
      self.is_a?(FalseClass) || self.is_a?(TrueClass)
    end
  end
end