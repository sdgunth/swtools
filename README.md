# SWTools (Star Wars Tools)

### So what is this, anyway?
SWTools is the GitHub home of one of my current projects, a web app to provide useful tools for Star Wars roleplaying games, Quests, writing, and so on.

### What can it do?

#### Random Species Select
This chooses a random Star Wars species (from a list of a bit under 300, which can be found in the species_list.json file). 

If that were all it did, however, it wouldn't be nearly as useful! By default, results are weighted by rarity and galactic location, and humans make up 40% of all results. These options can be changed via the various sliders, and additionally only species which have (or don't have) certain social statuses in the galaxy can be selected. While it is currently visually present, the Physiology and Biology tab settings do not affect results.

[Direct Link](http://swtools.herokuapp.com/generators/species-select)

###### To Do
- [ ] Finish converting the Generators to their own classes, and pull most of the generation logic out of swtools.rb
- [ ] Implement Physiology & Biology tabs
- [ ] Improve rarity regions (use more defined regions rather than the standard rings - Sernpidal and Dagobah should not be treated as adjacent to one another just because they're both in the Outer Rim)

### What _will_ it do?
- [ ] Random profession selection (by socioeconomic status, environment type, etc)
- [ ] Random Force-wielder generator (complete with powers, lightsaber styles if relevant, etc)
- [ ] Random character generation

### Where can I find it?
The current live version can always be found [here.](http://swtools.herokuapp.com/)
