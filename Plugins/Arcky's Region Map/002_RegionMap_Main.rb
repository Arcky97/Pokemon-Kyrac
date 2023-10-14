#===============================================================================
# UI stuff on loading the Region Map
#===============================================================================
class MapBottomSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    @questName   = ""
    @questTask   = ""
    @questLocation = ""
    self.bitmap = BitmapWrapper.new(Graphics.width, Graphics.height)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def questName=(value)
    return if @questName == value 
    @questName = value 
    refresh
  end 

  def questTask=(value)
    return if @questTask == value 
    @questTask = value 
    refresh
  end 

  def questLocation=(value)
    return if @questLocation == value 
    @questLocation = value 
    refresh
  end 

  def refresh
    bitmap.clear
    textpos = [
      [@mapname,                     18,   4, 0, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
      [@maplocation,                 18, 360, 0, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
      [@mapdetails, Graphics.width - 16, 360, 1, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
      [@questName,                  220,   4, 0, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(bitmap, textpos)
    drawFormattedTextEx(bitmap, 220, 40, 280, "#{@questTask}\n#{@questLocation}", TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR)
  end
end
#===============================================================================
# The Region Map and everything else it does and can do.
#===============================================================================
class PokemonRegionMap_Scene
  ZERO_POINT_X  = 0
  ZERO_POINT_Y  = 0
  QUESTPLUGIN = PluginManager.installed?("Modern Quest System + UI")
  CURSOR_MAP_OFFSET = RegionMapSettings::CURSOR_MAP_OFFSET ? SQUARE_WIDTH : 0

  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
    @showQuests = QUESTPLUGIN && RegionMapSettings::SHOW_QUEST_ICONS if !@wallmap
  end

  def pbStartScene(editor = false, flyMap = false)
    startFade 
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100000
    @viewportMap = Viewport.new(16, 32, 480, 320)
    @viewportMap.z = 99999
    @sprites = {}
    @spritesMap = {}
    @mapData = pbLoadTownMapData
    @flyMap = flyMap
    @mode    = flyMap ? 1 : 0
    mapMetadata = $game_map.metadata
    @playerPos = (mapMetadata) ? mapMetadata.town_map_position : nil
    getPlayerPosition(mapMetadata) 
    @questMap = $quest_data.getQuestMapPositions(@map) if $quest_data 
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    main 
  end

  def main 
    addBackgroundAndRegionSprite
    getVisitedMapInfo 
    recalculateFlyIconPositions 
    addFlyIconSprites 
    addUnvisitedMapSprites 
    showAndUpdateMapInfo 
    addPlayerIconSprite 
    addQuestIconSprites
    addCursorSprite 
    mapModeSwitchInfo 
    centerMapOnCursor
    refreshFlyScreen 
    stopFade { pbUpdate } 
  end 

  def startFade
    return if @FadeViewport || @FadeSprite
    @FadeViewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    @FadeViewport.z = 1000000
    @FadeSprite = BitmapSprite.new(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, @FadeViewport)
    @FadeSprite.bitmap.fill_rect(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, Color.new(0, 0, 0))
    @FadeSprite.opacity = 0
    for i in 0...(16 + 1)
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity += 256 / 16.to_f
    end
  end

  def getPlayerPosition(mapMetadata)
    @mapX   = ZERO_POINT_X
    @mapY   = ZERO_POINT_Y
    if !@playerPos
      @mapIndex = 0
      @map     = @mapData[0]
    elsif @region >= 0 && @region != @playerPos[0] && @mapData[@region]
      @mapIndex = @region
      @map     = @mapData[@region]
    else
      @mapIndex = @playerPos[0]
      @map     = @mapData[@playerPos[0]]
      @mapX    = @playerPos[1]
      @mapY    = @playerPos[2]
      mapsize = mapMetadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @mapX += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @mapY += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
  end 

  def addBackgroundAndRegionSprite
    @sprites["Background"] = IconSprite.new(0, 0, @viewport)
    @sprites["Background"].setBitmap("Graphics/Pictures/RegionMap/UI/mapBackGround")
    @sprites["Background"].x += (Graphics.width - @sprites["Background"].bitmap.width) / 2
    @sprites["Background"].y += (Graphics.height - @sprites["Background"].bitmap.height) / 2
    @sprites["Background"].z = 25
    @spritesMap["map"] = IconSprite.new(0, 0, @viewportMap)
    @spritesMap["map"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}")
    @spritesMap["map"].z = 1
    @mapWidth = adjustMapWidth #@spritesMap["map"].bitmap.width 
    @mapHeigth = adjustMapHeigth #@spritesMap["map"].bitmap.height
    RegionMapSettings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @mapIndex || !locationShown?(graphic)
      if !@spritesMap["map2"]
        @spritesMap["map2"] = BitmapSprite.new(480, 320, @viewportMap)
        @spritesMap["map2"].x = @spritesMap["map"].x
        @spritesMap["map2"].y = @spritesMap["map"].y
        @spritesMap["map2"].z = 6
      end

      pbDrawImagePositions(
        @spritesMap["map2"].bitmap,
        [["Graphics/Pictures/RegionMap/HiddenRegionMaps/#{graphic[4]}", graphic[2] * SQUARE_WIDTH, graphic[3] * SQUARE_HEIGHT]]
      )
    end
  end

  def adjustMapWidth
    RegionMapSettings::REGION_MAP_BY_SWITCH.each do |region|
      next if !$game_switches[region[1]]
      @pointMinX = region[2][0]
      return region[2][1] * SQUARE_WIDTH if region[2][1] * SQUARE_WIDTH <= @spritesMap["map"].bitmap.width
    end 
    return @spritesMap["map"].bitmap.width
  end 

  def adjustMapHeigth
    RegionMapSettings::REGION_MAP_BY_SWITCH.each do |region|
      next if !$game_switches[region[1]]
      @pointMinY = region[3][0]
      return region[3][1] * SQUARE_HEIGHT if region[3][1] * SQUARE_HEIGHT <= @spritesMap["map"].bitmap.height 
    end 
    return @spritesMap["map"].bitmap.height
  end 

  def locationShown?(point)
    return (point[5] == nil && point[1] > 0 && $game_switches[point[1]]) || point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def getVisitedMapInfo
    @unvisitedMaps = []
    @visitedMaps = []
    newMap = @map[2].sort_by { |index| [index[0], index[1]]}
    (ZERO_POINT_X..(@mapWidth / SQUARE_WIDTH)).each do |i|
      (ZERO_POINT_Y..(@mapHeigth / SQUARE_HEIGHT)).each do |j|
        healspot = pbGetHealingSpot(i, j)
        next if !healspot
        visited = $PokemonGlobal.visitedMaps[healspot[0]]
        map = newMap.find { |point| point[4] == healspot[0] && point[5] == healspot[1] && point[6] == healspot[2]}
        if visited
          @visitedMaps.push(map) if !@visitedMaps.include?(map)
        else
          @unvisitedMaps.push(map) if !@unvisitedMaps.include?(map)
        end
      end
    end
  end 

  def addFlyIconSprites
    if !@spritesMap["FlyIcons"]
      @spritesMap["FlyIcons"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["FlyIcons"].x = @spritesMap["map"].x
      @spritesMap["FlyIcons"].y = @spritesMap["map"].y
      @spritesMap["FlyIcons"].visible = @mode == 1
    end 
    @flyIconsPositions.each do |point|
      @spritesMap["FlyIcons"].z = 15
      iconName = @visitedMaps.find { |name| point[2] == name[2] } ? "mapFly" : "mapFlyDis"
      pbDrawImagePositions(
        @spritesMap["FlyIcons"].bitmap,
        [["Graphics/Pictures/RegionMap/Icons/#{iconName}", pointXtoScreenX(point[0]), pointYtoScreenY(point[1])]]
      )
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
  end 

  def pointXtoScreenX(x)
    return ((SQUARE_WIDTH * x + (SQUARE_WIDTH / 2)) - 16)
  end

  def pointYtoScreenY(y)
    return ((SQUARE_HEIGHT * y + (SQUARE_HEIGHT / 2)) - 16)
  end

  def addUnvisitedMapSprites
    if !@spritesMap["Visited"]
      @spritesMap["Visited"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["Visited"].x = @spritesMap["map"].x
      @spritesMap["Visited"].y = @spritesMap["map"].y
    end
    @unvisitedMaps.each do |visit|
      @spritesMap["Visited"].z = 8 
      pbDrawImagePositions(
        @spritesMap["Visited"].bitmap,
        [["Graphics/Pictures/RegionMap/Unvisited/map#{visit[8]}", ((visit[0] - 1) * SQUARE_WIDTH) , ((visit[1] - 1) * SQUARE_HEIGHT)]]
      )
    end
  end 

  def showAndUpdateMapInfo
    if !@sprites["mapbottom"]
      @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
      @sprites["mapbottom"].z = 30
    end
    @sprites["mapbottom"].mapname     = getMapName(@mapX, @mapY)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX, @mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX, @mapY)
    @sprites["mapbottom"].questName   = pbGetQuestName(@mapX, @mapY) if @showQuests
  end

  def getMapName(x, y)
    district = pbGetMessage(MessageTypes::RegionNames, @mapIndex)
    RegionMapSettings::REGION_DISTRICTS.each do |name|
      break if !RegionMapSettings::USE_REGION_DISTRICTS_NAMES
      next if name[0] != @mapIndex 
      if (x >= name[1][0] && x <= name[1][1]) && (y >= name[2][0] && y <= name[2][1])
        district = name[3]
      end 
    end
    return district 
  end

  def pbGetMapLocation(x, y)
    return "" if !@map[2]
    @routeType = ""
    @mapSize = [[] ,[], []]
    @spritesMap["highlight"].bitmap.clear if @spritesMap["highlight"]
    @map[2].each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (point[7] <= 0 || !$game_switches[point[7]])
      name = pbGetMessageFromHash(MessageTypes::PlaceNames, point[2])
      selectedMaps = @map[2].select { |point| point[2] == name }
      selectedMaps.each do |select|
        @mapSize[0].push(select[0..1]) if !@mapSize[0].include?(select[0..1])
        @mapSize[1].push(select[8]) if @mapSize[1].length != @mapSize[0].length && select[8] != ""
        @mapSize[2].push(select[2]) if !@mapSize[2].include?(select[2]) && select[2] != ""
      end
      next if @mapSize[0] == []
      transposed = @mapSize[0].transpose
      minValues = [transposed[0].min, transposed[1].min]
      @mapSize[3] = minValues
      colorCurrentLocation
      return name
    end
    return ""
  end

  def pbGetMapDetails(x, y)
    return "" if !@map[2]
    @map[2].each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      mapdesc = pbGetMessageFromHash(MessageTypes::PlaceDescriptions, point[3])
      return mapdesc
    end
    return ""
  end

  def pbGetQuestName(x, y)
    return "" if !@map[2] || !@questMap || @mode == 1 || !RegionMapSettings::SHOW_QUEST_ICONS || @wallmap
    questName = []
    value = ""
    @questMap.each do |name|
      next if name[1] != x || name[2] != y
      break if name[0] != @playerPos[0]
      @questNames = nil
      return value = "Invalid Quest Position" if !name[3]
      questName.push($quest_data.getName(name[3].id)) 
      if questName.length >= 2
        @questNames = questName 
        buttonName = convertButtonToString(RegionMapSettings::SHOW_QUEST_BUTTON)
        value = "#{questName.length} Quests (#{buttonName} to view)"
      else
        value = "Quest: #{questName[0]}"
      end
    end
    return value
  end 
  
  def convertButtonToString(button)
    case button 
    when 13 
      buttonName = "USE"
    when 14 
      buttonName = "JUMPUP"
    when 15
      buttonName = "JUMPDOWN"
    when 16
      buttonName = "SPECIAL"
    when 17
      buttonName = "AUX1"
    when 18
      buttonName = "AUX2"
    end 
    return buttonName
  end 

  def addPlayerIconSprite
    if @playerPos && @mapIndex == @playerPos[0]
      if !@spritesMap["player"]
        @spritesMap["player"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
        @spritesMap["player"].x = @spritesMap["map"].x
        @spritesMap["player"].y = @spritesMap["map"].y
      end 
      @spritesMap["player"].z = 60
      pbDrawImagePositions(
        @spritesMap["player"].bitmap,
        [[GameData::TrainerType.player_map_icon_filename($player.trainer_type), pointXtoScreenX(@mapX) , pointYtoScreenY(@mapY)]]
      )
    end
  end

  def addQuestIconSprites
    usedPositions = {}
    if !@spritesMap["QuestIcons"] && QUESTPLUGIN && RegionMapSettings::SHOW_QUEST_ICONS
      @spritesMap["QuestIcons"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["QuestIcons"].x = @spritesMap["map"].x
      @spritesMap["QuestIcons"].y = @spritesMap["map"].y
    end 
    return if !@spritesMap["QuestIcons"]
    @questMap.each do |index|
      next if index[0] != @playerPos[0]
      x = index[1]      
      y = index[2]      
      next if usedPositions.key?([x, y])
      next if index[4] && !$game_switches[index[4]] 
      @spritesMap["QuestIcons"].z = @spritesMap["player"].x == @spritesMap["QuestIcons"].x && @spritesMap["player"].y == @spritesMap["QuestIcons"].y ? 65 : 50
      pbDrawImagePositions(
        @spritesMap["QuestIcons"].bitmap,
        [["Graphics/Pictures/RegionMap/Icons/mapQuest", pointXtoScreenX(x) , pointYtoScreenY(y)]]
      )
      usedPositions[[x, y]] = true
    end
    @spritesMap["QuestIcons"].visible = @showQuests && @mode == 0
  end 

  def addCursorSprite
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/RegionMap/UI/mapCursor", 2, 5)
    @sprites["cursor"].viewport = @Viewport
    @sprites["cursor"].x        = 8 + SQUARE_WIDTH * @mapX 
    @sprites["cursor"].y        = 24 + SQUARE_HEIGHT * @mapY
    @sprites["cursor"].z        = 100000
    @sprites["cursor"].play
  end 

  def mapModeSwitchInfo
    if !@sprites["help"]
      @sprites["help"] = BitmapSprite.new(Graphics.width, 32, @Viewport)
      @sprites["help"].visible = pbGetQuestName(@mapX, @mapY).empty?
      pbSetSystemFont(@sprites["help"].bitmap)
    end 
    @sprites["help"].bitmap.clear
    return if @wallmap
    if @mode == 0 
      text = _INTL("ACTION: Fly")
      if RegionMapSettings::SHOW_QUEST_ICONS
        @showQuests = true if QUESTPLUGIN
        showAndUpdateMapInfo 
        @sprites["help"].visible = pbGetQuestName(@mapX, @mapY).empty?
      end
    else  
      text = _INTL("ACTION: Cancel Fly")
      if RegionMapSettings::CAN_QUICK_FLY && (RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY])
        button = convertButtonToString(RegionMapSettings::QUICK_FLY_BUTTON)
        text = _INTL("#{button}: Quick Fly")
      end
      if RegionMapSettings::SHOW_QUEST_ICONS
        @showQuests =  false if QUESTPLUGIN
        @sprites["mapbottom"].questName = ""
        clearQuestPreview
        @sprites["help"].visible = true 
      end
    end 
    pbDrawTextPositions(
      @sprites["help"].bitmap,
      [[text, Graphics.width - 16, 4, 1, Color.new(248, 248, 248), Color.new(0, 0, 0)]]
    )
    @sprites["help"].z = 100001
  end 

  def clearQuestPreview
    @sprites["mapbottom"].questTask   = ""
    @sprites["mapbottom"].questLocation = ""
  end 
  
  def centerMapOnCursor
    centerMapX
    centerMapY
    addArrowSprites if !@sprites["upArrow"]
    updateArrows
  end  

  def centerMapX
    mapMaxX = -1 * (@mapWidth - 480)
    if @sprites["cursor"].x > (Settings::SCREEN_WIDTH / 2)
      if @mapWidth > 480
        @spritesMap.each do |key, value|
          @spritesMap[key].x = ((480 / 2) - @sprites["cursor"].x) % 16 != 0 ? ((480 / 2) - @sprites["cursor"].x) + 8 : (480 / 2) - @sprites["cursor"].x 
        end 
        if @spritesMap["map"].x < mapMaxX
          @spritesMap.each do |key, value|
            @spritesMap[key].x = mapMaxX
          end 
        end    
      end
    else  
      @spritesMap.each do |key, value|
        @spritesMap[key].x = 0
      end
    end
    if RegionMapSettings::USE_REGION_BY_SWITCH
      RegionMapSettings::REGION_MAP_BY_SWITCH.each do | region |
        next if !$game_switches[region[1]]
        @spritesMap.each do |key, value|
          @spritesMap[key].x = -1 * ((region[2][0] + 1) * SQUARE_WIDTH)
        end
      end 
    end
    @sprites["cursor"].x += @spritesMap["map"].x
  end 

  def centerMapY
    mapMaxY = -1 * (@mapHeigth - 320)
    if @sprites["cursor"].y > (Settings::SCREEN_HEIGHT / 2)
      if @mapHeigth > 320
        @spritesMap.each do |key, value|
          @spritesMap[key].y = (320 / 2) - @sprites["cursor"].y % 16 != 0 ? ((320 / 2) - @sprites["cursor"].y) + 8 : (320 / 2) - @sprites["cursor"].y
        end 
        if @spritesMap["map"].y < mapMaxY
          @spritesMap.each do |key, value|
            @spritesMap[key].y = mapMaxY
          end 
        end    
      end
    else  
      @spritesMap.each do |key, value|
        @spritesMap[key].y = 0
      end
    end
    if RegionMapSettings::USE_REGION_BY_SWITCH
      RegionMapSettings::REGION_MAP_BY_SWITCH.each do | region |
        next if !$game_switches[region[1]]
        @spritesMap.each do |key, value|
          @spritesMap[key].y = -1 * ((region[3][0] + 1) * SQUARE_HEIGHT)
        end
      end 
    end
    @sprites["cursor"].y += @spritesMap["map"].y
  end 

  def addArrowSprites
    @sprites["upArrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["upArrow"].x = Graphics.width / 2
    @sprites["upArrow"].y = 16
    @sprites["upArrow"].z = 35
    @sprites["upArrow"].play 
    @sprites["downArrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downArrow"].x = Graphics.width / 2
    @sprites["downArrow"].y = Graphics.height - 60
    @sprites["downArrow"].z = 35
    @sprites["downArrow"].play
    @sprites["leftArrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftArrow"].y = Graphics.height / 2
    @sprites["leftArrow"].z = 35
    @sprites["leftArrow"].play
    @sprites["rightArrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightArrow"].x = Graphics.width - 40
    @sprites["rightArrow"].y = Graphics.height / 2
    @sprites["rightArrow"].z = 35
    @sprites["rightArrow"].play
  end 

  def updateArrows
    @sprites["upArrow"].visible = @spritesMap["map"].y < 0 ? true : false
    @sprites["downArrow"].visible = @spritesMap["map"].y > -1 * (@mapHeigth - 320) ? true : false
    @sprites["leftArrow"].visible =  @spritesMap["map"].x < 0 ? true : false 
    @sprites["rightArrow"].visible = @spritesMap["map"].x > -1 * (@mapWidth - 480) ? true : false
  end 

  def refreshFlyScreen
    return if @flyMap || !RegionMapSettings::CAN_FLY_FROM_TOWN_MAP || !pbCanFly?
    mapModeSwitchInfo
    distPerFrame = 8 * 20 / Graphics.frame_rate
    if @sprites["questPreview"]
      while @sprites["questPreview"].y <= 0 && @sprites["questPreview"].y != -120 do
        @sprites["questPreview"].y -= (120 / (SQUARE_WIDTH / distPerFrame))
        Graphics.update
      end 
      @sprites["questPreview"].visible = false if @sprites["questPreview"] && @sprites["questPreview"].y == -120
      @sprites["upArrow"].z = 35 if @sprites["upArrow"].z != 35
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
    @spritesMap["QuestIcons"].visible = @mode == 0 if QUESTPLUGIN && RegionMapSettings::SHOW_QUEST_ICONS
    @spritesMap["highlight"].bitmap.clear if @spritesMap["highlight"]
    colorCurrentLocation 
  end

  def stopFade
    return if !@FadeSprite || !@FadeViewport
    for i in 0...(16 + 1)
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity -= 256 / 16.to_f
    end
    @FadeSprite.dispose
    @FadeSprite = nil
    @FadeViewport.dispose
    @FadeViewport = nil
  end  

  def recalculateFlyIconPositions
    centerHash = {}
    matchingElements = []
    @flyIconsPositions = @visitedMaps.map(&:dup) + @unvisitedMaps.map(&:dup)
    @flyIconsPositions.each do |element|
      mapName = element[2]
      next if centerHash.key?(mapName)
      matchingElements = @map[2].select { |map| map[2] == mapName }
      if matchingElements.any?
        centerX = matchingElements.map { |map| map[0] }.sum.to_f / matchingElements.length
        centerY = matchingElements.map { |map| map[1] }.sum.to_f / matchingElements.length
        centerHash[mapName] = [centerX, centerY]
      end
    end
    @flyIconsPositions.each do |element|
      mapName = element[2]
      if centerHash.key?(mapName)
        element[0] = centerHash[mapName][0]
        element[1] = centerHash[mapName][1]
      end
    end
    return
  end  

  def colorCurrentLocation
    addHighlightSprites if !@spritesMap["highlight"]
    if @mode != 1 
      return if !@mapSize[1][0]
      index = @mapSize[0].index([@mapX, @mapY]) if @mapSize
      mapFolder = getMapFolderName(index)
      unless @mapSize[3][2] 
        @mapSize[3][0] -= 1 if !@mapSize[1][index].include?("Small") && !@mapSize[1][index].include?("Route") 
        @mapSize[3][1] -= 1 if !@mapSize[1][index].include?("Small") && !@mapSize[1][index].include?("Route")
        @mapSize[3][2] = true
      end 
      @mapSize[3] = @mapSize[0][index] if @mapSize[1][index] =~ /Small/
      pbDrawImagePositions(
        @spritesMap["highlight"].bitmap,
        [["Graphics/Pictures/RegionMap/Highlights/#{mapFolder}/map#{@mapSize[1][index]}", ((@mapSize[3][0]) * SQUARE_WIDTH) , ((@mapSize[3][1]) * SQUARE_HEIGHT)]]
      )
    else  
      flyMap = @flyIconsPositions.find { |map| map[2] == @mapSize[2][0] }
      return if !flyMap || @unvisitedMaps.find { |name| flyMap[2] == name[2] }
        pbDrawImagePositions(
          @spritesMap["highlight"].bitmap,
          [["Graphics/Pictures/RegionMap/Icons/MapFlySel", (flyMap[0] * SQUARE_WIDTH) - 8 , (flyMap[1] * SQUARE_HEIGHT) - 8]]
        )
    end
  end

  def addHighlightSprites
    @spritesMap["highlight"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
    @spritesMap["highlight"].x = @spritesMap["map"].x
    @spritesMap["highlight"].y = @spritesMap["map"].y
    @spritesMap["highlight"].visible = true 
    @spritesMap["highlight"].z = 20
  end 

  def getMapFolderName(index)
    case @mapSize[1][index]
    when /Size/
      mapFolder = "Others"
    when /Route/
      mapFolder = "Routes"
    end
    return mapFolder
  end 

  def pbMapScene
    cursor = [0, 0, 0, 0, 0, 0] 
    map    = [0, 0, 0, 0, 0, 0] 
    choice   = nil
    lastChoiceFly = 0
    lastChoiceQuest = 0
    distPerFrame = 8 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if cursor[0] != 0 || cursor[1] != 0
        updateCursor(cursor, distPerFrame)
        updateMap(map, distPerFrame) if map[0] != 0 || map[1] != 0
        next 
      end
      if map[0] != 0 || map[1] != 0
        updateMap(map, distPerFrame)
        next 
      end
      if cursor[0] == 0 && cursor[1] == 0 && choice && choice >= 0 
        inputFly = true if !@showQuests 
        lastChoiceQuest = choice if @mode == 0
        lastChoiceFly = choice if @mode == 1
        choice = nil
      end
      updateArrows
      ox, oy, mox, moy = 0, 0, 0, 0
      cursor[4] = @mapX
      cursor[5] = @mapY
      ox, oy, mox, moy = getDirectionInput(ox, oy, mox, moy)
      choice = canActivateQuickFly(lastChoiceFly, cursor)
      updateCursorPosition(ox, oy, cursor) if ox != 0 || oy != 0
      updateMapPosition(mox, moy, map) if mox != 0 || moy != 0
      showAndUpdateMapInfo if @mapX != cursor[4] || @mapY != cursor[5]
      clearQuestPreview if @mapX != cursor[4] || @mapY != cursor[5]
      @sprites["help"].visible = pbGetQuestName(@mapX, @mapY).empty?
      if (Input.trigger?(Input::USE) && @mode == 1) || inputFly 
        return @healspot if getFlyLocationAndConfirm { pbUpdate }
      elsif Input.trigger?(RegionMapSettings::SHOW_QUEST_BUTTON) && QUESTPLUGIN && @showQuests 
        choice = showQuestInformation(lastChoiceQuest, distPerFrame)
      elsif Input.trigger?(Input::ACTION) && !@wallmap && !@flyMap && pbCanFly? && RegionMapSettings::CAN_FLY_FROM_TOWN_MAP
        switchMapMode
      end
      break if Input.trigger?(Input::BACK)
    end
    pbPlayCloseMenuSE
    return nil
  end

  def updateCursor(cursor, distPerFrame)
    cursor[0] += (cursor[0] > 0) ? -distPerFrame : (cursor[0] < 0) ? distPerFrame : 0
    cursor[1] += (cursor[1] > 0) ? -distPerFrame : (cursor[1] < 0) ? distPerFrame : 0
    @sprites["cursor"].x = cursor[2] - cursor[0]
    @sprites["cursor"].y = cursor[3] - cursor[1]
    @sprites["questPreview"].y -= (120 / (SQUARE_WIDTH / distPerFrame)) if @sprites["questPreview"] && @sprites["questPreview"].y <= 0 && @sprites["questPreview"].y != -120
    @sprites["questPreview"].visible = false if @sprites["questPreview"] && @sprites["questPreview"].y == -120 
    @sprites["upArrow"].z = 35 if @sprites["upArrow"].z != 35
  end 

  def updateMap(map, distPerFrame)
    map[0] += (map[0] > 0) ? -distPerFrame : (map[0] < 0) ? distPerFrame : 0
    map[1] += (map[1] > 0) ? -distPerFrame : (map[1] < 0) ? distPerFrame : 0
    @spritesMap.each do |key, value|
      @spritesMap[key].x = map[2] - map[0]
      @spritesMap[key].y = map[3] - map[1]
    end
    @sprites["questPreview"].y -= (120 /(SQUARE_WIDTH / distPerFrame)) if @sprites["questPreview"] && @sprites["questPreview"].y <= 0 && @sprites["questPreview"].y != -120
    @sprites["questPreview"].visible = false if @sprites["questPreview"] && @sprites["questPreview"].y == -120
    @sprites["upArrow"].z = 35 if @sprites["upArrow"].z != 35
  end 

  def getDirectionInput(ox, oy, mox, moy)
    case Input.dir8
    when 1, 2, 3
      oy = 1 if @sprites["cursor"].y < (320 - CURSOR_MAP_OFFSET)
      moy = -1 if @spritesMap["map"].y > -1 * (@mapHeigth - 320) && oy == 0
    when 7, 8, 9
      oy = -1 if @sprites["cursor"].y > (32 + CURSOR_MAP_OFFSET)
      moy = 1 if @spritesMap["map"].y < 0 && oy == 0
    end
    case Input.dir8
    when 1, 4, 7
      ox = -1 if @sprites["cursor"].x > (16 + CURSOR_MAP_OFFSET)
      mox = 1 if @spritesMap["map"].x < 0 && ox == 0
    when 3, 6, 9
      ox = 1 if @sprites["cursor"].x < (464 - CURSOR_MAP_OFFSET)
      mox = -1 if @spritesMap["map"].x > -1 * (@mapWidth - 480) && ox == 0
    end
    return ox, oy, mox, moy
  end

  def canActivateQuickFly(lastChoiceFly, cursor)
    if RegionMapSettings::CAN_QUICK_FLY && Input.trigger?(RegionMapSettings::QUICK_FLY_BUTTON) && @mode == 1 && 
      (RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY])
      findChoice = @visitedMaps.find_index { |mapName| mapName[2] == pbGetMapLocation(@mapX, @mapY)}
      lastChoiceFly = findChoice if findChoice
      choice = pbMessageMap(_INTL("Quick Fly: Choose one of the available locations to fly to."), 
          (0...@visitedMaps.size).to_a.map{|i| 
            next _INTL("#{@visitedMaps[i][2]}")
          }, -1, nil, lastChoiceFly) { pbUpdate }
      if choice != -1 && @visitedMaps[choice][2] != pbGetMapLocation(@mapX, @mapY)
        @mapX = @visitedMaps[choice][0]
        @mapY = @visitedMaps[choice][1]
      elsif choice == -1
        @mapX = cursor[4]
        @mapY = cursor[5]
      end
      @sprites["cursor"].x = 8 + (@mapX * SQUARE_WIDTH)
      @sprites["cursor"].y = 24 + (@mapY * SQUARE_HEIGHT)
      pbGetMapLocation(@mapX, @mapY)
      centerMapOnCursor
    end
    return choice
  end 

  def updateCursorPosition(ox, oy, cursor)
    @mapX += ox
    @mapY += oy
    cursor[0] = ox * SQUARE_WIDTH
    cursor[1] = oy * SQUARE_HEIGHT
    cursor[2] = @sprites["cursor"].x + cursor[0]
    cursor[3] = @sprites["cursor"].y + cursor[1]
  end 

  def updateMapPosition(mox, moy, map)
    @mapX -= mox 
    @mapY -= moy
    map[0] = mox * SQUARE_WIDTH
    map[1] = moy * SQUARE_HEIGHT 
    map[2] = @spritesMap["map"].x + map[0]
    map[3] = @spritesMap["map"].y + map[1]
  end 

  def getFlyLocationAndConfirm
    @healspot = pbGetHealingSpot(@mapX, @mapY)
    if @healspot && ($PokemonGlobal.visitedMaps[@healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
      name = pbGetMapNameFromId(@healspot[0])
      return pbConfirmMessageMap(_INTL("Would you like to use Fly to go to {1}?", name)) 
    end
  end 

  def showQuestInformation(lastChoiceQuest, distPerFrame)
    return if @wallmap
    questInfo = @questMap.select { |coords| coords && coords[0..2] == [@playerPos[0], @mapX, @mapY] }
    questInfo = [] if questInfo.empty? || (questInfo[0][4] && !$game_switches[questInfo[0][4]])
    return if questInfo == []
    input, quest, choice = getCurrentQuestInfo(lastChoiceQuest, questInfo)
    if input && quest
      name = $quest_data.getName(quest.id)
      description = "Task: #{$quest_data.getStageDescription(quest.id, quest.stage)}"
      description = "Task: Not given!" if description == "Task: "
      location = "Location: #{$quest_data.getStageLocation(quest.id, quest.stage)}"
      location = "Location: Unknown!" if location == "Location: " 
      @sprites["mapbottom"].questName = "Quest: #{name}"
      showQuestPreview(distPerFrame)
      @sprites["mapbottom"].questTask   = description.to_s
      @sprites["mapbottom"].questLocation = location.to_s
    end
    return choice 
  end 

  def getCurrentQuestInfo(lastChoiceQuest, questInfo)
    if @questNames
      choice = pbMessageMap(_INTL("Which quest would you like to view info about?"), 
      (0...@questNames.size).to_a.map{|i| 
        next _INTL("#{@questNames[i]}")
      }, -1, nil, lastChoiceQuest) { pbUpdate }
      input = true if choice != -1
      quest = questInfo[choice][3]
    else 
      input = true
      quest = questInfo[0][3]
    end
    return input, quest, choice 
  end 

  def showQuestPreview(distPerFrame)
    if !@sprites["questPreview"]
      @sprites["questPreview"] = IconSprite.new(0, 0, @viewport) 
      @sprites["questPreview"].setBitmap("Graphics/Pictures/RegionMap/UI/mapQuestPreview")
      @sprites["questPreview"].z = 20
      @sprites["questPreview"].visible = false
    end
    makeBitmapVisible(distPerFrame) if !@sprites["questPreview"].visible
  end 

  def makeBitmapVisible(distPerFrame)
    @sprites["questPreview"].y = -120
    @sprites["questPreview"].visible = true
    @sprites["upArrow"].z = 15
    until @sprites["questPreview"].y == 0 do 
      @sprites["questPreview"].y += (120 / (SQUARE_WIDTH / distPerFrame))
      Graphics.update
    end
  end

  def switchMapMode
    pbPlayDecisionSE
    @mode = @mode == 1 ? 0 : 1
    refreshFlyScreen
  end 

  def pbConfirmMessageMap(message, &block)
    return (pbMessageMap(message, [_INTL("Yes"), _INTL("No")], 2, nil, 0, false, &block) == 0)
  end

  def pbMessageMap(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, choiceUpdate = true, &block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil, skin)
    msgwindow.z = 100001
    if commands
      ret = pbMessageDisplay(msgwindow, message, true,
                             proc { |msgwindow|
                               next pbShowCommandsMap(msgwindow, commands, cmdIfCancel, defaultCmd, choiceUpdate, &block)
                             }, &block)
    else
      pbMessageDisplay(msgwindow, message, &block)
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
  end
  
  def pbShowCommandsMap(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0, choiceUpdate = true)
    return 0 if !commands
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 100001
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    cmdwindow.index = defaultCmd
    command = 0
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if choiceUpdate && RegionMapSettings::AUTO_CURSOR_MOVEMENT && !@showQuests
        @mapX = @visitedMaps[cmdwindow.index][0]
        @mapY = @visitedMaps[cmdwindow.index][1]
        @sprites["cursor"].x = 8 + (@mapX * SQUARE_WIDTH)
        @sprites["cursor"].y = 24 + (@mapY * SQUARE_HEIGHT)
        showAndUpdateMapInfo
        centerMapOnCursor
      end 
      msgwindow&.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel > 0
          command = cmdIfCancel - 1
          break
        elsif cmdIfCancel < 0
          command = cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbEndScene
    startFade { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@spritesMap)
    @viewport.dispose
    @viewportMap.dispose
    stopFade
  end
end
#===============================================================================
# Fly Region Map
#===============================================================================
class PokemonRegionMapScreen
  def pbStartScreen
    @scene.pbStartScene
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end
end
#===============================================================================
# Debug menu editor
#===============================================================================
class RegionMapSpritE
  def createRegionMap(map)
    @mapdata = pbLoadTownMapData
    @map = @mapdata[map]
    bitmap = AnimatedBitmap.new("Graphics/Pictures/RegionMap/Regions/#{@map[1]}").deanimate
    retbitmap = BitmapWrapper.new(bitmap.width / 2, bitmap.height / 2)
    retbitmap.stretch_blt(
      Rect.new(0, 0, bitmap.width / 2, bitmap.height / 2),
      bitmap,
      Rect.new(0, 0, bitmap.width, bitmap.height)
    )
    bitmap.dispose
    return retbitmap
  end
end