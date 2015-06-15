class Species < ActiveRecord::Base
  if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
    serialize :social_status
    serialize :rarities_by_region
  elsif ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
    store_accessor :social_status
    store_accessor :rarities_by_region
  else
  end
end