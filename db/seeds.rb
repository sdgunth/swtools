require 'json'

species_file = File.read('species_list.json')
species_hash = JSON.parse(species_file)

species_hash.each do |i|
  bio = i['biology']
  rarity = i['rarity and origin']
    
  Species.create(
    :name => i['name'],
    :social_status => i['social_status'],
    :size => bio['size'],
    :diet => bio['diet'],
    :genders => bio['genders'],
    :males_per_female => bio['males per female'],
    :force_sensitivity => bio['force sensitivity'],
    :lifespan => bio['lifespan'],
    :home_region => bio['home region'],
    :home_region_rarity => bio['home rarity'],
    :rarities_by_region => {
      "Deep Core" => rarity['deep core'],
      "Galactic Core" => rarity['galactic core'],
      "Colonies" => rarity['colonies'],
      "Inner Rim" => rarity['inner rim'],
      "Expansion Region" => rarity['expansion region'],
      "Mid Rim" => rarity['mid rim'],
      "Outer Rim" => rarity['outer rim'],
      "Wild Space" => rarity['wild space'],
      "Tingel Arm" => rarity['tingel arm'],
      "Unknown Regions" => rarity['unknown regions']
    },
    :wiki_link => 'http://starwars.wikia.com/' + i['name']
  ) 
end