class Species < ActiveRecord::Base
  if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
    serialize :social_status
    serialize :rarities_by_region
  else
    store_accessor :social_status
    store_accessor :rarities_by_region
  end
end