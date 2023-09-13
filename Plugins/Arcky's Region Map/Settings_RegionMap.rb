
#===============================================================================
# Turn certain settings on/off according to your preferences.
#===============================================================================
module RegionMapSettings
    #===============================================================================
    # Folder for Visited/Unvisited Places.
    #===============================================================================
    # - Set this to False if you want the content of the folder named "Unvisited" be used by the script. 
    #   This means that all flyable places should have any color you want on the RegionMap image.
    # - Set this to false if you want the content of the folder named "Visited" be used by the script. 
    #   This means that all flyable places should have a color that indicates the location hasn't been visited yet by default on the RegionMap image.
    USE_UNVISITED_FOLDER = true
    #===============================================================================
    # Route Set-up method
    #===============================================================================
    # - Set this to true if you want to use the complex Set-up method for the highlighting of Routes.
    #   check the Relice Castle thread for a detailed guide: 
    # - Set this to false if you want to use the easy Set-up method for the highlighting of Routes.
    #   This requires you to provide each Route, in the highlighted color you prefer, as an individual image.
    SET_UP_METHOD = true
    #===============================================================================
    # Hidden Region Locations
    #===============================================================================
    # - This is similar to the REGION_MAP_EXTRAS you set-up in the Settings script section.
    #   Why it is here? Well this is simply because 


end

