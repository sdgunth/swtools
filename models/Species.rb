class Species < ActiveRecord::Base
  serialize :social_status
  serialize :rarities_by_region
end