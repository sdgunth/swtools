class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :name
      if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
        t.string :rarities_by_region
      else
        t.hstore :rarities_by_region
      end
      # Social Statuses
      t.boolean :liked
      t.boolean :respected
      t.boolean :beloved
      t.boolean :enslaved
      t.boolean :denigrated
      t.boolean :feared
      t.boolean :hated
      t.boolean :mysterious
      t.boolean :neutral

      t.string :bodily_structure
      t.string :size
      t.string :biology_type
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