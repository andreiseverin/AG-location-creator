#include <amxmodx> 
#include <rog> 
#include <fakemeta> 
#include <float>


#define PLUGIN	"AG Location creator"
#define VERSION	"1.0"
#define AUTHOR	"teylo"

new const BIG_GRID_SIZE = 3;
new const SMALL_GRID_SIZE = 3;
// Buffer to write the file
new buffer[16384];

new direction[][16] = {
  "South-West",
  "West",
  "North-West",
  "South",
  "Center",
  "North",
  "South-East",
  "East",
  "North-East"
};

public plugin_init() 
{ 

	register_plugin(
		PLUGIN,		//: AG Location creator
		VERSION,	//: 1.0
		AUTHOR		//: teylo
	);

	// Verify existing location
	LoadLocations() 
	// Get existing points inside the map perimeter
	ROGInitialize(10.0) // distance between points
	//ROGDumpOriginData() // get how many points were created

	// Get the min&max x,y,z coordinates of the map
	CalculateMinMax()


} 

public CalculateMinMax()
{
	// the min value will have the highest possible value and the max the lowest
	new Float:minx=4096.0,maxx=-4096.0,miny=4096.0,maxy=-4096.0,minz=4096.0,maxz=-4096.0;

	//Calculate max and max
	new Float:EntityOrigin[3], i
	new Size = ArraySize(FoundOriginsArray)
	
	for(i = 0; i < Size; i++)
	{ 
		ArrayGetArray(FoundOriginsArray, i, EntityOrigin)
		// x
		minx = floatmin(minx,EntityOrigin[0])
		maxx = floatmax(maxx,EntityOrigin[0])
		// y
		miny = floatmin(miny,EntityOrigin[1])
		maxy = floatmax(maxy,EntityOrigin[1])
		// z
		minz = floatmin(minz,EntityOrigin[2])
		maxz = floatmax(maxz,EntityOrigin[2])
   
	}
	//server_print("say Min x : %.1f || Max x : %.1f",minx,maxx)
	//server_print("say Min y : %.1f || Max y : %.1f",miny,maxy)
	//server_print("say Min z : %.1f || Max z : %.1f",minz,maxz)

	calculate_locs_positions(minx,maxx,miny,maxy,minz,maxz)
}

public LoadLocations() 
{
	new mapFile[64];
	
	{
		new mapName[32];
		get_mapname(mapName, charsmax(mapName));

		new file[64];
		new handleDir = open_dir("locs", file, charsmax(file));
		do {
			if (equali(file, fmt("%s.loc", mapName))) {
				formatex(mapFile, charsmax(mapFile), "locs/%s", file);
				break;
			}
		} while (next_file(handleDir, file, charsmax(file)));
		close_dir(handleDir);
	}

	new handle = fopen(mapFile, "r");

	if (handle)
	{
		server_print("Map location file already existing: %s", mapFile)
		StopPlugin();
		return false;
	}

}

// ===== PLUGIN STOP ==============
stock StopPlugin() 
{
	new pluginName[32];
	get_plugin(-1, pluginName, sizeof(pluginName));
	pause("d", pluginName);
	return;
}

public calculate_locs_positions(min_x , max_x , min_y , max_y , min_z ,max_z) 
{


	// Z grid system : Top, Middle, Bottom
	// > 1200 => 3 grids
	// 600 < x <= 1200 => 2 grids
	// < 600 =< 1 grid
  	new grid_count;

  	if (floatsub(max_z,min_z) < 600) {
		grid_count = 1;
  	} else if (floatsub(max_z,min_z) < 1200) {
		grid_count = 2;
  	} else {
		grid_count = 3;
 	}
 	new grid_height = floatsub(max_z,min_z) / grid_count;
	//server_print("A!!! grid_height %f",grid_height);
	// Calculate BIG GRID width and height
	new big_grid_width = floatsub(max_x,min_x) / BIG_GRID_SIZE;
	new big_grid_height = floatsub(max_y,min_y) / BIG_GRID_SIZE;
	//server_print("A!!! big_grid_width: %f  big_grid_height: %f",big_grid_width,big_grid_height);
	// Calculate SMALL GRID width and height
	new small_grid_width = floatsub(big_grid_width,0) / SMALL_GRID_SIZE; //using floatsub cuz the division doesnt work properly
	new small_grid_height = floatsub(big_grid_height,0) / SMALL_GRID_SIZE;
	//server_print("A!!! small_grid_width: %f  small_grid_height: %f",small_grid_width,small_grid_height);

  // Iterate over each big grid cell
	for (new i = 0; i < BIG_GRID_SIZE; i++) 
	{
		for (new j = 0; j < BIG_GRID_SIZE; j++) 
		{

			// Write the compass direction for the big grid cell
	  		new direction_index = i * BIG_GRID_SIZE + j;
	  		new direction_string[16];

			//
	  		format(direction_string, sizeof direction_string, "%s", direction[direction_index]);
			//server_print("=================  %s ====================",direction_string); 
	  		new big_grid_min_x = floatsub(min_x,0) + i * floatsub(big_grid_width,0);
	  		new big_grid_min_y = floatsub(min_y,0) + j * floatsub(big_grid_height,0);

			//server_print("B!!! big_grid_min_x: %f  big_grid_min_y: %f",big_grid_min_x,big_grid_min_y);

	  		// Iterate over each small grid cell within the big grid cell
	  		for (new k = 0; k < SMALL_GRID_SIZE; k++) 
			{
				for (new l = 0; l < SMALL_GRID_SIZE; l++) 
				{
		  			new center_x = floatsub(big_grid_min_x,0) + (k + 0.5) * floatsub(small_grid_width,0);
		  			new center_y = floatsub(big_grid_min_y,0) + (l + 0.5) * floatsub(small_grid_height,0);
					//server_print("C!!! center_x: %f  center_y: %f",center_x,center_y);
		  			// Write the "Zone 1, 2, 3, etc." for the small grid cell
		  			new zone = k * BIG_GRID_SIZE + l + 1; 
		  			new direction_and_zone_string[32];
		  			format(direction_and_zone_string, sizeof direction_and_zone_string, "%s %d", direction_string, zone);
					//server_print("%s#%.1f#%.1f#",  direction_and_zone_string,center_x, center_y);

		  			// Do something with center_x, center_y and direction_and_zone_string

					// Iterate over each z grid
  					for (new m = 0; m < grid_count; m++) 
					{
						new grid_min_z = floatsub(min_z,0) + m * floatsub(grid_height,0);
						new grid_max_z = floatsub(grid_min_z,0) + floatsub(grid_height,0);
						new center_z = floatsub(grid_min_z,0) + (floatsub(grid_height,0) / 2);

   						// Do something with center_z, grid_min_z, and grid_max_z

						// get z grid position and write the buffer within the iteration
						// loc format : Name of the zone # x # y # z #
						new direction_string_z[32];
						if (grid_count == 2) {
	  						if (m == 0) {
								format(direction_string_z, 32, " Down");
								format(buffer, 16384, "%s%s%s#%.1f#%.1f#%.1f#", buffer, direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
								//server_print("%s%s#%.1f#%.1f#%.1f#",  direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
	  						} else {
								format(direction_string_z, 32, " Up");
								format(buffer, 16384, "%s%s%s#%.1f#%.1f#%.1f#", buffer, direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
								//server_print("%s%s#%.1f#%.1f#%.1f#",  direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
	  						}
						}
						if (grid_count == 3) {
	  						if (m == 0) {
								format(direction_string_z, 32, " Down");
								format(buffer, 16384, "%s%s%s#%.1f#%.1f#%.1f#", buffer, direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
								//server_print("%s%s#%.1f#%.1f#%.1f#",  direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
	  						} else if (m == 1) {
								format(direction_string_z, 32, " Mid");
								format(buffer, 16384, "%s%s%s#%.1f#%.1f#%.1f#", buffer, direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
								//server_print("%s%s#%.1f#%.1f#%.1f#",  direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
	  						} else {
								format(direction_string_z, 32, " Up");
								format(buffer, 16384, "%s%s%s#%.1f#%.1f#%.1f#", buffer, direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
								//server_print("%s%s#%.1f#%.1f#%.1f#", direction_and_zone_string, direction_string_z,center_x, center_y, center_z);
	  						}
						}
							
  					} 
				
				}
	  		} 
		}
  	}
	
	// Write the locs into the file
	new mapName[32];
	get_mapname(mapName, charsmax(mapName));

 	new file_path[128];
  	format(file_path, 127, "locs/%s.loc", mapName);

  	if(file_exists(file_path) != 1) { 
		server_print("Creating map file: %s.loc", mapName)
    	write_file(file_path,buffer)
    	return 1;
  	} else {
		server_print("Map file: %s.loc not written", mapName)
    	return 0;
  	} 
}
