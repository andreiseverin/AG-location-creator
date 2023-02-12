## Adrenaline Gamer location creator
 
 ![Adrenaline Gamer location creator](https://repository-images.githubusercontent.com/600182318/68d676d4-b8e5-46b2-8eda-6e53ebbaa9af)
 
 This plugin aims to create location files for all the maps that don't have one. The loc files are usefull in Adrenaline Gamer to share your location with your team mates. Normally, all the location have been done by hand using `addloc name` in the old ag 6.6 client. If you need a certain loc for a map, just install this plugin and lanch that map. A location will be automatically created in the `ag/locs` folder.
 
 ## Database download - over 3100 maps
 
 Go to [Releases](https://github.com/andreiseverin/AG-location-creator/releases/tag/v1.0) and download the database that works with your client.
 
 ## How it works
 
 The plugin recovers all the playable points on the map whith a distance of 10.0 between every point. These points are going to be mapped into a (x,y,z) coordinate system. The recovered coordinates will be compared to get the `min` and `max` for each axys.
 Once we have the borders, we are going to split the region into a 3x3 big grid. Each big grid will be names after compass directions: `North` , `South`, `West`, `East`, `North-West`, `North-East`, `South-West`, `South-East` and `Center`. After the BIG GRID system, we resplit each grid into a 3x3 SMALL GRID SYSTEM, numbered from `1` to `9`. 
 Here's an example for the map `boot_camp`:
 
 ![boot_camp](https://i.imgur.com/PiCLhf3.png)
 
 Then for the `z axys`, I put a check between `z min` and `z max`, getting the map heigh. Once it has the height it splits the `z axys` into a number of grids as follows:
 ```bash
	- heigh > 1200            // => 3 grids
	- 600 < heigh <= 1200     // => 2 grids
	- heigh< 600              // => 1 grid
 ```
 For `3 grids` system we have : `Up`, `Mid` and `Down`
 For `2 grids` system we have : `Up` and `Down`
 For `1 grid` system we add nothing
 
 In the end, each location will be as follows: ex: `North-West 1 Mid` or `South-East 9 Down`.
 
 Initially, the location were like ex: `North-West - Zone 1 - Middle` or `South-East - Zone 9 - Down` but the client couldn't read more than 8KiB (hardcoded). A fix has been delivered in [BugfixedHL v1.9.1](https://github.com/tmp64/BugfixedHL-Rebased), but due to most of the clients having the read buffer limited, I choosed to maintain the first naming system. In the future, an upgrade can be done.
 
 
