require 'json'

species_file = File.read('species_list.json')
species_array = JSON.parse(species_file)

species_array.each do |i|
  bio = i['biology']
  rarity = i['rarity and origin']
  social = i['social status']
    
  new_spec = Species.new
  new_spec[:name] = i['name']
  new_spec[:liked] = social['liked']
  new_spec[:respected] = social['respected']
  new_spec[:beloved] = social['beloved']
  new_spec[:enslaved] = social['enslaved']
  new_spec[:denigrated] = social['denigrated']
  new_spec[:feared] = social['feared']
  new_spec[:hated] = social['hated']
  new_spec[:neutral] = social['neutral']
  new_spec[:mysterious] = social['mysterious']
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
  if i['wiki link']
    new_spec[:wiki_link] = 'http://starwars.wikia.com/wiki/' + i['wiki link']
  else
    new_spec[:wiki_link] = 'http://starwars.wikia.com/wiki/' + i['name']
  end
  new_spec.save
end