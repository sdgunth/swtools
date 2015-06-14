require 'json'

species_file = File.read('species_list.json')
species_array = JSON.parse(species_file)

species_array.each do |i|
  bio = i['biology']
  rarity = i['rarity and origin']
    
  new_spec = Species.new
  puts "Adding name"
  new_spec[:name] = i['name']
    puts "Adding social status"
  new_spec[:social_status] = i['social_status']
  new_spec[:size] = bio['size']
  new_spec[:diet] = bio['diet']
  new_spec[:genders] = bio['genders']
  new_spec[:males_per_female] = bio['males per female']
  new_spec[:force_sensitivity] = bio['force sensitivity']
  new_spec[:lifespan] = bio['lifespan']
  new_spec[:home_region] = rarity['home region']
  new_spec[:home_region_rarity] = rarity['home rarity']
  new_spec[:rarities_by_region] = {
    "Deep Core" => rarity['deep core'],
    "Core Worlds" => rarity['core worlds'],
    "Colonies" => rarity['colonies'],
    "Inner Rim" => rarity['inner rim'],
    "Expansion Region" => rarity['expansion region'],
    "Mid Rim" => rarity['mid rim'],
    "Outer Rim Territories" => rarity['outer rim territories'],
    "Wild Space" => rarity['wild space'],
    "Tingel Arm" => rarity['tingel arm'],
    "Unknown Regions" => rarity['unknown regions']
  }
  new_spec[:wiki_link] = 'http://starwars.wikia.com/wiki/' + i['name']
end