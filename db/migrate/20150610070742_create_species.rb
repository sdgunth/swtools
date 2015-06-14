class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :name
      if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
        t.string :social_status
        t.string :rarities_by_region
      else
        t.hstore :social_status
        t.hstore :rarities_by_region
      end
      t.string :size
      t.string :diet
      t.string :genders
      t.float :males_per_female
      t.string :force_sensitivity
      t.string :lifespan
      t.string :home_region
      t.string :home_region_rarity
      t.string :wiki_link
    end
  end
end
