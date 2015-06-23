# Public: This is the subclass of Generator for selecting a species from the list
# of Star Wars species. 
#
# It assumes species are held in a table called Species. 
class SWSpeciesSelector < Generator
  @supported_comparable_traits = {
    :sizes => ["Tiny", "Small", "Average", "Large", "Huge"],
    :lifespan => ["Short", "Normal", "Long", "Very Long", "Indefinite"]
  }
    
  def compare_values(comparator, arg, *other_args)
    # If being given a range
    if comparator.class == Range
      trait = nil
      # Iterate through supported comparable traits, figuring out which one is being looked into
      @supported_comparable_traits.each do |key, val|
        val.include?(arg) ? (trait = key) : nil
      end
      # Make sure that the arg and the comparator are frm the SAME trait
      if ((@supported_comparable_traits[trait].include? comparator.begin) && 
          (@supported_comparable_traits[trait].include? comparator.end))
        # Make sure the range conversion is the right level of exclusivity
        if comparator.exlude_end?
          converted_range = 
            @supported_comparable_traits[trait].index(comparator.begin)...
            @supported_comparable_traits[trait].index(comparator.end)
        else
          converted_range = 
            @supported_comparable_traits[trait].index(comparator.begin)..
            @supported_comparable_traits[trait].index(comparator.end)
        end
        return (converted_range.cover? @supported_comparable_traits[trait].index(arg))
      else
        raise("#{arg} is not between #{comparator.begin} and #{comparator.end}")
      end
    elsif arg.boolean?
      if other_args[0].boolean?
        arg.send(comparator, other_args[0])
      else
        raise("Tried to compare a boolean to a not-boolean")
      end
    end
    raise("Something went wrong! Attempted to evaluate #{arg} (#{arg.class})" << 
          "#{comparator} (#{comparator.class}) #{other_args[0]} (#{other_args[0].class})")
  end
end

# Internal: Monkey patches object to check if a value is boolean
class Object
  def boolean?
    self.is_a?(FalseClass) || self.is_a?(TrueClass)
  end
end