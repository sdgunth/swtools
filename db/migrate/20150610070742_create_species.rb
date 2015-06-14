class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :name
      t.string :social_status
      t.string :size
      t.string :diet
      t.string :genders
      t.float :males_per_female
      t.string :force_sensitivity
      t.string :lifespan
      t.string :home_region
      t.string :home_region_rarity
      t.string :rarities_by_region
      t.string :wiki_link
    end
  end
end
