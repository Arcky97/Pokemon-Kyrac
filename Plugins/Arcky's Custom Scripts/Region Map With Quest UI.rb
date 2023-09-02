#===============================================================================
#
#===============================================================================
class MapBottomSprite < Sprite
    attr_reader :mapname, :maplocation
  
    TEXT_MAIN_COLOR   = Color.new(248, 248, 248)
    TEXT_SHADOW_COLOR = Color.new(0, 0, 0)
  
    def initialize(viewport = nil)
      super(viewport)
      @mapname     = ""
      @maplocation = ""
      @mapdetails  = ""
      #@questActives = getActiveQuests
      @questName   = ""
      self.bitmap = BitmapWrapper.new(Graphics.width, Graphics.height)
      pbSetSystemFont(self.bitmap)
      refresh
    end

    def mapname=(value)
      return if @mapname == value
      @mapname = value
      refresh
    end
  
    def maplocation=(value)
      return if @maplocation == value
      @maplocation = value
      refresh
    end
  
    # From Wichu
    def mapdetails=(value)
      return if @mapdetails == value
      @mapdetails = value
      refresh
    end
  
    def questName=(value)
      return if @questName == value 
      @questName = value 
      refresh
    end 

    def refresh
      bitmap.clear
      textpos = [
        [@mapname,                     18,   4, 0, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [@maplocation,                 18, 360, 0, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [@mapdetails, Graphics.width - 16, 360, 1, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [@questName,     Graphics.width - 16,  4, 1, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR]
      ]
      pbDrawTextPositions(bitmap, textpos)
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class PokemonRegionMap_Scene
    LEFT          = 0
    TOP           = 0
    RIGHT         = 29
    BOTTOM        = 19
    SQUARE_WIDTH  = 16
    SQUARE_HEIGHT = 16
  
    def initialize(region = - 1, wallmap = true, quest = false)
      @region  = region
      @wallmap = wallmap
      @showQuests = quest
    end
  
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene(as_editor = false, fly_map = false)
      as_editor = false
      @editor   = as_editor
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      @map_data = pbLoadTownMapData
      @fly_map = fly_map
      @mode    = fly_map ? 1 : 0
      map_metadata = $game_map.metadata
      playerpos = (map_metadata) ? map_metadata.town_map_position : nil
      if !playerpos
        mapindex = 0
        @map     = @map_data[0]
        @map_x   = LEFT
        @map_y   = TOP
      elsif @region >= 0 && @region != playerpos[0] && @map_data[@region]
        mapindex = @region
        @map     = @map_data[@region]
        @map_x   = LEFT
        @map_y   = TOP
      else
        mapindex = playerpos[0]
        @map     = @map_data[playerpos[0]]
        @map_x    = playerpos[1]
        @map_y    = playerpos[2]
        mapsize = map_metadata.town_map_size
        if mapsize && mapsize[0] && mapsize[0] > 0
          sqwidth  = mapsize[0]
          sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
          @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
          @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
          end
      end
      getQuestMapPositions
      if !@map
        pbMessage(_INTL("The map data cannot be found."))
        return false
      end
      addBackgroundOrColoredPlane(@sprites, "background", "RegionMap/UI/mapbg", Color.new(0, 0, 0), @viewport)
      @sprites["map"] = IconSprite.new(0, 0, @viewport)
      @sprites["map"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}")
      @sprites["map"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
      @sprites["map"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
      @sprites["map"].z = 10
      @sprites["mapCities"] = IconSprite.new(0, 0, @viewport)
      @sprites["mapCities"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}Cities")
      @sprites["mapCities"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
      @sprites["mapCities"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
      @sprites["mapCities"].z = 20
      @sprites["mapRoutes"] = IconSprite.new(0, 0, @viewport)
      @sprites["mapRoutes"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}Routes")
      @sprites["mapRoutes"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
      @sprites["mapRoutes"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
      @sprites["mapRoutes"].z = 15
      @sprites["mapLocations"] = IconSprite.new(0, 0, @viewport)
      @sprites["mapLocations"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}Locations")
      @sprites["mapLocations"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
      @sprites["mapLocations"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
      @sprites["mapLocations"].z = 25
      Settings::REGION_MAP_EXTRAS.each do |graphic|
        next if graphic[0] != mapindex || !location_shown?(graphic)
        if !@sprites["map2"]
          @sprites["map2"] = BitmapSprite.new(480, 320, @viewport)
          @sprites["map2"].x = @sprites["map"].x
          @sprites["map2"].y = @sprites["map"].y
        end
        pbDrawImagePositions(
          @sprites["map2"].bitmap,
          [["Graphics/Pictures/RegionMap/HiddenRegionMaps/#{graphic[4]}", graphic[2] * SQUARE_WIDTH, graphic[3] * SQUARE_HEIGHT]]
        )
      end
      @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
      @sprites["mapbottom"].mapname     = pbGetMessage(MessageTypes::RegionNames, mapindex)
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
      @sprites["mapbottom"].questName   = pbGetQuestName(@map_x, @map_y) if @showQuests
      if playerpos && mapindex == playerpos[0]
        @sprites["player"] = IconSprite.new(0, 0, @viewport)
        @sprites["player"].setBitmap(GameData::TrainerType.player_map_icon_filename($player.trainer_type))
        @sprites["player"].x = point_x_to_screen_x(@map_x)
        @sprites["player"].y = point_y_to_screen_y(@map_y)
        @sprites["player"].z = 9997
      end
      k = 0
      @foundMaps = []
      (LEFT..RIGHT).each do |i|
        (TOP..BOTTOM).each do |j|
          healspot = pbGetHealingSpot(i, j)
          next if !healspot || !$PokemonGlobal.visitedMaps[healspot[0]]
          findMap = @map[2].find { |point| point[4] == healspot[0] && point[5] == healspot[1] && point[6] == healspot[2]}
          @foundMaps.push(findMap) if !@foundMaps.include?(findMap)
          @sprites["point#{k}"] = AnimatedSprite.create("Graphics/Pictures/RegionMap/Icons/mapFly", 2, 16)
          @sprites["point#{k}"].viewport = @viewport
          @sprites["point#{k}"].x        = point_x_to_screen_x(i)
          @sprites["point#{k}"].y        = point_y_to_screen_y(j)
          @sprites["point#{k}"].z        = 50
          @sprites["point#{k}"].visible  = @mode == 1
          @sprites["point#{k}"].play
          k += 1
        end
      end
      usedPositions = {}
      @questMap.each do |index|
        x = index[1]      # The x-coordinate of the quest
        y = index[2]      # The y-coordinate of the quest
        if usedPositions.key?([x, y])
          next # Skip drawing if the position is already occupied
        end
        echoln(@showQuests)
        @sprites["mapQuest#{index}"] = AnimatedSprite.create("Graphics/Pictures/RegionMap/Icons/mapQuest", 2, 16)
        @sprites["mapQuest#{index}"].viewport = @viewport
        @sprites["mapQuest#{index}"].x        = point_x_to_screen_x(x)
        @sprites["mapQuest#{index}"].y        = point_y_to_screen_y(y)
        @sprites["mapQuest#{index}"].visible  = @showQuests == true #&& $game_switches[index[4]]
        @sprites["mapQuest#{index}"].play
        @sprites["mapQuest#{index}"].z        = @sprites["player"].x == @sprites["mapQuest#{index}"].x && @sprites["player"].y == @sprites["mapQuest#{index}"].y ? 9998 : 50
        usedPositions[[x, y]] = true
      end
      @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/RegionMap/UI/mapCursor", 2, 5)
      @sprites["cursor"].viewport = @viewport
      @sprites["cursor"].x        = point_x_to_screen_x(@map_x)
      @sprites["cursor"].y        = point_y_to_screen_y(@map_y)
      @sprites["cursor"].z        = 9999
      @sprites["cursor"].play
      @sprites["help"] = BitmapSprite.new(Graphics.width, 32, @viewport)
      pbSetSystemFont(@sprites["help"].bitmap)
      refresh_fly_screen
      @changed = false
      pbFadeInAndShow(@sprites) { pbUpdate }
    end
  
    def pbEndScene
      pbFadeOutAndHide(@sprites)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
  
    def point_x_to_screen_x(x)
      return (-SQUARE_WIDTH / 2) + (x * SQUARE_WIDTH) + ((Graphics.width - @sprites["map"].bitmap.width) / 2)
    end
  
    def point_y_to_screen_y(y)
      return (-SQUARE_HEIGHT / 2) + (y * SQUARE_HEIGHT) + ((Graphics.height - @sprites["map"].bitmap.height) / 2)
    end
  
    def location_shown?(point)
      #return point[5] if @wallmap
      return point[1] > 0 && $game_switches[point[1]]
    end
  
    def pbSaveMapData
      File.open("PBS/town_map.txt", "wb") { |f|
        Compiler.add_PBS_header_to_file(f)
        @map_data.length.times do |i|
          map = @map_data[i]
          next if !map
          f.write("\#-------------------------------\r\n")
          f.write(sprintf("[%d]\r\n", i))
          f.write(sprintf("Name = %s\r\n", Compiler.csvQuote(map[0])))
          f.write(sprintf("Filename = %s\r\n", Compiler.csvQuote(map[1])))
          map[2].each do |loc|
            f.write("Point = ")
            Compiler.pbWriteCsvRecord(loc, f, [nil, "uussUUUU"])
            f.write("\r\n")
          end
        end
      }
    end
  
    def pbGetMapLocation(x, y)
      return "" if !@map[2]
      @mapSize = [[] ,[]]
      @sprites["map3"].bitmap.clear if @sprites["map3"]
      @map[2].each do |point|
        next if point[0] != x || point[1] != y
        return "" if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
        name = pbGetMessageFromHash(MessageTypes::PlaceNames, point[2])
        mapInfos = pbLoadMapInfos
        mapInfos.each do |mapId| 
          map = GameData::MapMetadata.try_get(mapId[0])
          next if !map || map.name != name
          selectedMaps = @map[2].select { |point| point[2] == name }
          selectedMaps.each do |select|
            @mapSize[0].push(select[0..1])
            @mapSize[1].push(select[8])
          end
          @mapSize.push(map.town_map_size || [1, "1"])
        end
        colorCurrentLocation(@mapSize)
        return (@editor) ? point[2] : name
      end
      return ""
    end
  
    def colorCurrentLocation(mapSize)
      if !@sprites["map3"]
        @sprites["map3"] = BitmapSprite.new(480, 320, @viewport)
        @sprites["map3"].x = @sprites["map"].x
        @sprites["map3"].y = @sprites["map"].y
      end
      pbDrawImagePositions(
        @sprites["map3"].bitmap,
        [["Graphics/Pictures/RegionMap/map-#{mapSize[1][0]}-#{mapSize[2][1]}-M", ((mapSize[0][0][0] - 1) * SQUARE_WIDTH) , ((mapSize[0][0][1] - 1) * SQUARE_HEIGHT)]]
      )
      #We need to draw all cities and locations again on the region map so these are on top of the orange markings of routes. Only we don't do this when a location or city
      #is marked. so we can do a check on the type of location.
      @map[2].each do |point| 
        if point[0] == (mapSize[0][0][0] - 1) && point[1] == mapSize[0][0][1]
          nearPoint = [point[0], point[1]]
          pbDrawImagePositions(
            @sprites["map3"].bitmap,
            [["Graphics/Pictures/RegionMap/map-City-1111-N", (((mapSize[0][0][0] - 1) * SQUARE_WIDTH) - 32) , ((mapSize[0][0][1] - 1) * SQUARE_HEIGHT)]]
          )
        end 
      end
=begin
      @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pointcolor = Color.new(0, 248, 248)
      pointcolorhl = Color.new(192, 248, 248)
      town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
      sqwidth = PokemonRegionMap_Scene::SQUARE_WIDTH
      sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
      mapSize.each do |x, y|
        x *= sqwidth 
        y *= sqheight
        @sprites["areahighlight"].bitmap.fill_rect(x + 16, y + 32, sqwidth, sqheight, pointcolor)
        @sprites["areahighlight"].z = 9995
      end
      echoln("The given map size is #{mapSize}")
=end
    end

    def pbChangeMapLocation(x, y)
      return "" if !@editor || !@map[2]
      map = @map[2].select { |loc| loc[0] == x && loc[1] == y }[0]
      currentobj  = map
      currentname = (map) ? map[2] || "" : ""
      currentname = pbMessageFreeText(_INTL("Set the name for this point."), currentname, false, 250) { pbUpdate }
      if currentname
        if currentobj
          currentobj[2] = currentname
        else
          newobj = [x, y, currentname, ""]
          @map[2].push(newobj)
        end
        @changed = true
      end
    end
  
    def pbGetMapDetails(x, y)   # From Wichu, with my help
      return "" if !@map[2]
      @map[2].each do |point|
        next if point[0] != x || point[1] != y
        return "" if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
        mapdesc = pbGetMessageFromHash(MessageTypes::PlaceDescriptions, point[3])
        return (@editor) ? point[3] : mapdesc
      end
      return ""
    end
  
    def pbGetQuestName(x, y)
      return "" if !@map[2]
      questName = []
      value = ""
      @questMap.each do |name|
        next if name[1] != x || name[2] != y
        @questNames = nil
        #next if !$game_switches[name[4]]
        questName.push($quest_data.getName(name[3].id)) 
        if questName.length >= 2
          @questNames = questName 
          value = "#{questName.length} Quests (press to view)"
        else
          value = "Quest: #{questName[0]}"
        end
      end
      return value
    end 

    def pbGetHealingSpot(x, y)
      return nil if !@map[2]
      @map[2].each do |point|
        next if point[0] != x || point[1] != y
        return nil if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
        return (point[4] && point[5] && point[6]) ? [point[4], point[5], point[6]] : nil
      end
      return nil
    end
  
    def refresh_fly_screen
      return if @fly_map || !Settings::CAN_FLY_FROM_TOWN_MAP || !pbCanFly?
      @sprites["help"].bitmap.clear
      text = (@mode == 0) ? _INTL("ACTION: Fly") : _INTL("ACTION: Cancel Fly")
      pbDrawTextPositions(
        @sprites["help"].bitmap,
        [[text, Graphics.width - 16, 36, 1, Color.new(248, 248, 248), Color.new(0, 0, 0)]]
      )
      @sprites.each do |key, sprite|
        next if !key.include?("point")
        sprite.visible = (@mode == 1)
        sprite.frame   = 0
      end
    end
  
    def getQuestMapPositions
      @questMap = []
      activeQuests = $PokemonGlobal.quests.active_quests
      activeQuests.each do |quest|
          mapId = ("Map" + "#{quest.stage}").to_sym
          map = QuestModule.const_get(quest.id)[mapId]
          findMap = @map[2].find { |point| point[0] == map[1] && point[1] == map[2] }
          map.push(quest, findMap[7]) if !map.include?(quest) && !map.include?(findMap[7])
          @questMap.push(map) if map  
      end
    end

    def pbMapScene
      x_offset = 0
      y_offset = 0
      new_x    = 0
      new_y    = 0
      old_x    = 0
      old_y    = 0
      dist_per_frame = 8 * 20 / Graphics.frame_rate
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if x_offset != 0 || y_offset != 0
          x_offset += (x_offset > 0) ? -dist_per_frame : (x_offset < 0) ? dist_per_frame : 0
          y_offset += (y_offset > 0) ? -dist_per_frame : (y_offset < 0) ? dist_per_frame : 0
          @sprites["cursor"].x = new_x - x_offset
          @sprites["cursor"].y = new_y - y_offset
          next
        end
        ox = 0
        oy = 0
        old_x = @map_x
        old_y = @map_y
        case Input.dir8
        when 1, 2, 3
          oy = 1 if @map_y < BOTTOM
        when 7, 8, 9
          oy = -1 if @map_y > TOP
        end
        case Input.dir8
        when 1, 4, 7
          ox = -1 if @map_x > LEFT
        when 3, 6, 9
          ox = 1 if @map_x < RIGHT
        end
        if ox != 0 || oy != 0
          @map_x += ox
          @map_y += oy
          x_offset = ox * SQUARE_WIDTH
          y_offset = oy * SQUARE_HEIGHT
          new_x = @sprites["cursor"].x + x_offset
          new_y = @sprites["cursor"].y + y_offset
        end
        if @map_x != old_x || @map_y != old_y
          @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
          @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
          @sprites["mapbottom"].questName   = pbGetQuestName(@map_x, @map_y) if @showQuests
        end
        if Input.trigger?(Input::BACK)
          if @editor && @changed
            pbSaveMapData if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
            break if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
          else
            break
          end
        elsif Input.trigger?(Input::USE) && @mode == 1   # Choosing an area to fly to
          healspot = pbGetHealingSpot(@map_x, @map_y)
          if healspot && ($PokemonGlobal.visitedMaps[healspot[0]] ||
             ($DEBUG && Input.press?(Input::CTRL)))
            return healspot if @fly_map
            name = pbGetMapNameFromId(healspot[0])
            return healspot if pbConfirmMessage(_INTL("Would you like to use Fly to go to {1}?", name)) { pbUpdate }
          end
        elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
          pbChangeMapLocation(@map_x, @map_y)
        elsif Input.trigger?(Input::USE) && @showQuests
          questInfo = @questMap.select { |coords| coords && coords[1] == @map_x && coords[2] == @map_y }
          if questInfo != [] #&& $game_switches[questInfo[0][4]]
            if @questNames
              choice = pbMessage(_INTL("Which quest would you like to view info about?"), 
              (0...@questNames.size).to_a.map{|i| 
                next _INTL("#{@questNames[i]}")
              }, -1)
              input = true if choice != -1
              questToView = questInfo[choice][3]
            else 
              input = pbConfirmMessage(_INTL("Would you like to view this quest in the Quest menu?")) 
              questToView = questInfo[0][3]
            end
            if input
              scene = QuestList_Scene.new
              scene.pbStartScene
              scene.pbQuest(questToView)
              if Input.trigger?(Input::BACK)
                scene.pbEndScene
              end 
            end
          end
        elsif Input.trigger?(Input::ACTION) && !@wallmap && !@fly_map && pbCanFly?
          pbPlayDecisionSE
          @mode = (@mode == 1) ? 0 : 1
          refresh_fly_screen
        end
      end
      pbPlayCloseMenuSE
      return nil
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class PokemonRegionMapScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartFlyScreen
      @scene.pbStartScene(false, true)
      ret = @scene.pbMapScene
      @scene.pbEndScene
      return ret
    end
  
    def pbStartScreen
      @scene.pbStartScene($DEBUG)
      ret = @scene.pbMapScene
      @scene.pbEndScene
      return ret
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  def pbShowMap(region = -1, wallmap = true)
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(region, wallmap)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      $game_temp.fly_destination = ret if ret && !wallmap
    }
  end