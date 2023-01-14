
def pbBetterRegionMap(region = -1, show_player = true, can_fly = false, wallmap = false, species = nil)
  scene = BetterRegionMap.new(region, show_player, can_fly, wallmap, species)
  return scene.flydata
end

class PokemonGlobalMetadata
  attr_writer :regionMapSel
  attr_writer :region

  def regionMapSel
    @regionMapSel ||= [0, 0]
    return @regionMapSel
  end

  def region
    @region ||= 0
    return @region
  end
end


def regionArray
  regionmapinfo = [[$game_switches[140], 0, 0, "MapRegion0"], [$game_switches[135], 24, 4, "MapRegion1"], [$game_switches[136], 27, 14, "MapRegion2"], [$game_switches[137], 30, 33, "MapRegion3"]]
  for i in 0...regionmapinfo.length
    if regionmapinfo[i][0]  
      regiondata = regionmapinfo[i].clone
    end
  end
  return regiondata
end

def changePlayerPos
  position = $game_map ? $game_map.metadata&.town_map_position.clone : nil
  position[1] -= regionArray[1]
  if $game_switches[85] # the player is on the yacht
    case $game_variables[47] # check value of the game variable ID 47
    when 1 
      position[1] += 1
    when 2
      position[1] += 2
    when 3
      position[1] += 3
    when 4
      position[1] += 4
    when 5
      position[1] += 5
    end
  end
  return position
end

def changeTownMapData(region)
  newdata = load_data("Data/town_map.dat")[region].clone
  for i in 0...regionArray[2]
    if !nil
      newdata[2][i][0] -= regionArray[1]
    end
  end
  return newdata
end


class BetterRegionMap
  CursorAnimateDelay = 12.0
  CursorMoveSpeed = 4.0
  TileWidth = 16.0
  TileHeight = 16.0

  FlyPointAnimateDelay = 20.0

  attr_reader :flydata

  def initialize(region = -1, show_player = true, can_fly = true, wallmap = false, species = nil)
    showBlk
    playerpos = changePlayerPos
    @region = (region < 0) ? playerpos[0] : region
    @species = species
    @show_player = (show_player && playerpos[0] == @region)
    @can_fly = can_fly
    @data = changeTownMapData(region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @mapvp = Viewport.new(16, 32, 480, 320)
    @mapvp.z = 100000
    @mapoverlayvp = Viewport.new(16,32,480,320)
    @mapoverlayvp.z = 100001
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 100001
    @sprites = SpriteHash.new
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bmp("Graphics/Pictures/mapbg")
    @window = SpriteHash.new
    @window["map"] = Sprite.new(@mapvp)
    @window["map"].bmp("Graphics/Pictures/#{regionArray[3]}")
    for hidden in Settings::REGION_MAP_EXTRAS
      if hidden[0] == @region && ((wallmap && hidden[5]) || # always show if looking at wall map, irrespective of switch
                                   (!wallmap && hidden[1] > 0 && $game_switches[hidden[1]]))
        if !@window["map2"]
          @window["map2"] = BitmapSprite.new(480,320,@mapoverlayvp)
        end
        pbDrawImagePositions(@window["map2"].bitmap, [
          ["Graphics/Pictures/#{hidden[4]}", hidden[2] * TileWidth, hidden[3] * TileHeight, 0, 0, -1, -1],
        ])
      end
    end
    @window["player"] = Sprite.new(@mapoverlayvp)
    if @show_player
      map_metadata = $game_map.metadata
      if playerpos[0] == @region
        mapsize = map_metadata.town_map_size
        gender = $Trainer.gender.to_digits(3)
        @map_x = playerpos[1] 
        @map_y =  playerpos[2] 
        if mapsize != nil
          sqwidth  = mapsize[0]
          sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        else
          sqwidth = 1
          sqheight = 1
        end
        @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
        @window["player"].bmp("Graphics/Pictures/mapPlayer#{gender}")
        @window["player"].x = TileWidth * @map_x + (TileWidth / 2.0)
        @window["player"].y = TileHeight * @map_y + (TileHeight / 2.0)
        @window["player"].center_origins
      end
    end
    @window["areahighlight"] = BitmapSprite.new(@window["map"].bitmap.width,@window["map"].bitmap.height,@mapoverlayvp)
    @window["areahighlight"].y = - 8
    # pokedex highlights
    if @species != nil
      @window["areahighlight"].bitmap.clear
      # Fill the array "points" with all squares of the region map in which the
      # species can be found
      
      mapwidth = @window["map"].bitmap.width/BetterRegionMap::TileWidth
      data = calculatePointsAndCenter(mapwidth)

      points = data[0]
      minxy = data[1]
      maxxy = data[2]
      
      # Draw coloured squares on each square of the region map with a nest
      pointcolor   = Color.new(0,248,248)
      pointcolorhl = Color.new(192,248,248)
      
      sqwidth = TileWidth.round
      sqheight = TileHeight.round
      
      for j in 0...points.length
        if points[j]
          x = (j % mapwidth) * sqwidth
          y = (j / mapwidth) * sqheight
          @window["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
          if j - mapwidth < 0 || !points[j - mapwidth]
            @window["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
          end
          if j + mapwidth >= points.length || !points[j + mapwidth]
            @window["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
          end
          if j % mapwidth == 0 || !points[j - 1]
            @window["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
          end
          if (j + 1) % mapwidth == 0 || !points[j + 1]
            @window["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
          end
        end
      end
    end
    
    @sprites["cursor"] = Sprite.new(@viewport2)
    @sprites["cursor"].bmp("Graphics/Pictures/mapCursor")
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height
    
    if @species != nil && minxy[0] != nil && maxxy[1] != nil
      @map_x = ((minxy[0] + maxxy[0]) / 2).round
      @map_y = ((minxy[1] + maxxy[1]) / 2).round
    else
      map_metadata = $game_map.metadata
      mapsize = map_metadata.town_map_size
      @map_x = playerpos[1] 
      @map_y =  playerpos[2] 
      if mapsize != nil
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
      else
        sqwidth = 1
        sqheight = 1
      end
      @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
      @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
    end
    
    @sprites["cursor"].x = 16 + TileWidth * @map_x
    @sprites["cursor"].y = 32 + TileHeight * @map_y
    
    @sprites["cursor"].z = 11
    
    # Center the window on the cursor
    windowminx = -1 * (@window["map"].bmp.width / 2)
    windowminx = 0 if windowminx > 0
    windowminy = -1 * (@window["map"].bmp.height / 2)
    windowminy = 0 if windowminy > 0
    
    mapwidth = @window["map"].bmp.width
    mapheigth = @window["map"].bmp.height
    
    if @sprites["cursor"].x > (Settings::SCREEN_WIDTH / 2)
      if mapwidth > Settings::SCREEN_WIDTH
        @window.x = (Settings::SCREEN_WIDTH / 2 ) - @sprites["cursor"].x
        if (@window.x < windowminx)
          @window.x = windowminx
        end     
      end
      @sprites["cursor"].x += @window.x
    end
    if @sprites["cursor"].y > (Settings::SCREEN_HEIGHT / 2)
      if mapheigth > Settings::SCREEN_HEIGHT
        @window.y = (Settings::SCREEN_HEIGHT / 2 ) - @sprites["cursor"].y
        if @window.y < windowminy
          @window.y = windowminy
        end   
      end
      @sprites["cursor"].y += @window.y
    end
    
    @sprites["cursor"].ox = (@sprites["cursor"].bmp.height - TileWidth) / 2.0
    @sprites["cursor"].oy = @sprites["cursor"].ox
    @sprites["txt"] = TextSprite.new(@viewport)
    @sprites["arrowLeft"] = Sprite.new(@viewport2)
    @sprites["arrowLeft"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowLeft"].mirror = true
    @sprites["arrowLeft"].center_origins
    @sprites["arrowLeft"].xyz = 12, Graphics.height / 2
    @sprites["arrowRight"] = Sprite.new(@viewport2)
    @sprites["arrowRight"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowRight"].center_origins
    @sprites["arrowRight"].xyz = Graphics.width - 12, Graphics.height / 2
    @sprites["arrowUp"] = Sprite.new(@viewport2)
    @sprites["arrowUp"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowUp"].angle = 180
    @sprites["arrowUp"].center_origins
    @sprites["arrowUp"].xyz = Graphics.width / 2, 24
    @sprites["arrowDown"] = Sprite.new(@viewport2)
    @sprites["arrowDown"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowDown"].center_origins
    @sprites["arrowDown"].xyz = Graphics.width / 2, Graphics.height - 24

    update_text
    @dirs = []
    @mdirs = []
    @i = 0

    if can_fly
      @spots = {}
      n = 0
      for x in 0...(@window["map"].bmp.width / TileWidth)
        for y in 0...(@window["map"].bmp.height / TileHeight)
          healspot = pbGetHealingSpot(x, y)
          if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
            @window["point#{n}"] = Sprite.new(@mapvp)
            @window["point#{n}"].bmp("Graphics/Pictures/mapFly")
            @window["point#{n}"].src_rect.width = @window["point#{n}"].bmp.height
            @window["point#{n}"].x = TileWidth * x + (TileWidth / 2)
            @window["point#{n}"].y = TileHeight * y + (TileHeight / 2)
            @window["point#{n}"].oy = @window["point#{n}"].bmp.height / 2.0
            @window["point#{n}"].ox = @window["point#{n}"].oy
            @spots[[x, y]] = healspot
            n += 1
          end
        end
      end
    end

    hideBlk { update(false) }
    main
  end

  def pbGetHealingSpot(x, y)
    return nil if !@data[2]
    @data[2].each do |point|
      next if point[0] != x || point[1] != y
      return nil if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      return (point[4] && point[5] && point[6]) ? [point[4], point[5], point[6]] : nil
    end
    return nil
  end

  def main
    loop do
      update
      if Input.press?(Input::RIGHT) && ![4, 6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x < 480
          @map_x += 1
          @sx = @sprites["cursor"].x
          @dirs << 6
        elsif @window.x > -1 * (@window["map"].bmp.width - 480)
          @map_x += 1
          @mx = @window.x
          @mdirs << 6
        end
      end
      if Input.press?(Input::LEFT) && ![4, 6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x > 16
          @map_x -= 1
          @sx = @sprites["cursor"].x
          @dirs << 4
        elsif @window.x < 0
          @map_x -= 1
          @mx = @window.x
          @mdirs << 4
        end
      end
      if Input.press?(Input::DOWN) && ![2, 8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y <= 320
          @map_y += 1
          @sy = @sprites["cursor"].y
          @dirs << 2
        elsif @window.y > -1 * (@window["map"].bmp.height - 320)
          @map_y += 1
          @my = @window.y
          @mdirs << 2
        end
      end
      if Input.press?(Input::UP) && ![2, 8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y > 32
          @map_y -= 1
          @sy = @sprites["cursor"].y
          @dirs << 8
        elsif @window.y < 0
          @map_y -= 1
          @my = @window.y
          @mdirs << 8
        end
      end
      if Input.trigger?(Input::C)
        x, y = @map_x, @map_y
        if @spots && @spots[[x, y]]
          @flydata = @spots[[x, y]]
          break
        end
      end
      break if Input.trigger?(Input::B)
    end
    dispose
  end

  def update(update_gfx = true)
    @sprites["arrowLeft"].visible = @window.x < 0
    @sprites["arrowRight"].visible = @window.x > -1 * (@window["map"].bmp.width - 480)
    @sprites["arrowUp"].visible = @window.y < 0
    @sprites["arrowDown"].visible = @window.y > -1 * (@window["map"].bmp.height - 320)

    if update_gfx
      Graphics.update
      Input.update
    end
    
    intensity = (Graphics.frame_count % 40) * 12
    intensity = 480 - intensity if intensity > 240
    @window["areahighlight"].opacity = intensity
    
    @i += 1
    if @i % CursorAnimateDelay == 0
      @sprites["cursor"].src_rect.x += @sprites["cursor"].src_rect.width
      @sprites["cursor"].src_rect.x = 0 if @sprites["cursor"].src_rect.x >= @sprites["cursor"].bmp.width
    end
    if @i % FlyPointAnimateDelay == 0
      @window.keys.each do |e|
        next unless e.to_s.start_with?("point")
        @window[e].src_rect.x += @window[e].src_rect.width
        @window[e].src_rect.x = 0 if @window[e].src_rect.x >= @window[e].bmp.width
      end
    end

    if @i % 2 == 0
      case @i % 32
      when 0...8
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      when 8...24
        @sprites["arrowLeft"].x += 1
        @sprites["arrowRight"].x -= 1
        @sprites["arrowUp"].y += 1
        @sprites["arrowDown"].y -= 1
      when 24...32
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      end
    end

    # Cursor movement
    if @dirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(6)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(4)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(8)
        @ver_count = nil
        @sy = nil
      end
    end
    if @dirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(2)
        @ver_count = nil
        @sy = nil
      end
    end

    # Map movement
    if @mdirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(6)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(4)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(8)
        @ver_count = nil
        @my = nil
      end
    end
    if @mdirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(2)
        @ver_count = nil
        @my = nil
      end
    end
  end

  def update_text
    location = @data[2].find do |e|
      e[0] == @map_x &&
      e[1] == @map_y
    end
    text = ""
    text = location[2] if location
    poi = ""
    poi = location[3] if location && location[3]
    @sprites["txt"].draw([
      [pbGetMessage(MessageTypes::RegionNames, @region), 18, 4, 0,
       Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [text, 16, 360, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [poi, 496, 360, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ], true)
  end

  def dispose
    showBlk { update(false) }
    @sprites.dispose
    @window.dispose
    @viewport.dispose
    @viewport2.dispose
    @mapvp.dispose
    hideBlk
    Input.update
  end
end

#==============================================================================#
# Overwrites some old methods to use the new region map                        #
#==============================================================================#

ItemHandlers::UseFromBag.add(:TOWNMAP, proc { |item|
  next (pbBetterRegionMap(-1, true, false)) ? 2 : 0 #(@region, show player ,allow flying)
})

ItemHandlers::UseInField.add(:TOWNMAP, proc { |item|
  pbFadeOutIn(99999) {
    ret = pbBetterRegionMap(-1, true, true) #(@region, show player ,allow flying)
    $game_temp.fly_destination = ret if ret
  }
  next (pbFlyToNewLocation) ? 1 : 0
})

MenuHandlers.add(:pokegear_menu, :map, {
  "name"      => _INTL("Map"),
  "icon_name" => "map",
  "order"     => 10,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      ret = pbBetterRegionMap
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    }
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pause_menu, :town_map, {
  "name"      => _INTL("Town Map"),
  "order"     => 40,
  "condition" => proc { next !$player.has_pokegear && $bag.has?(:TOWNMAP) },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      ret = pbBetterRegionMap
      $game_temp.fly_destination = ret if ret
      ($game_temp.fly_destination) ? menu.pbEndScene : menu.pbRefresh
    }
    next pbFlyToNewLocation
  }
})

class PokemonRegionMapScreen
  def pbStartFlyScreen
    ret = pbBetterRegionMap(-1, true, true)
    return ret
  end
end


class PokemonPartyScreen
  def pbPokemonScreen
    can_access_storage = false
    if ($player.has_box_link || $bag.has?(:POKEMONBOXLINK)) &&
        !$game_switches[Settings::DISABLE_BOX_LINK_SWITCH] &&
        !$game_map.metadata&.has_flag?("DisableBoxLink")
      can_access_storage = true
    end
    @scene.pbStartScene(@party,
                        (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),
                        nil, false, can_access_storage)
    # Main loop
    loop do
      # Choose a Pokémon or cancel or press Action to quick switch
      @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      party_idx = @scene.pbChoosePokemon(false, -1, 1)
      break if (party_idx.is_a?(Numeric) && party_idx < 0) || (party_idx.is_a?(Array) && party_idx[1] < 0)
      # Quick switch
      if party_idx.is_a?(Array) && party_idx[0] == 1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        old_party_idx = party_idx[1]
        party_idx = @scene.pbChoosePokemon(true, -1, 2)
        pbSwitch(old_party_idx, party_idx) if party_idx >= 0 && party_idx != old_party_idx
        next
      end
      # Chose a Pokémon
      pkmn = @party[party_idx]
      # Get all commands
      command_list = []
      commands = []
      MenuHandlers.each_available(:party_menu, self, @party, party_idx) do |option, hash, name|
        command_list.push(name)
        commands.push(hash)
      end
      command_list.push(_INTL("Cancel"))
      # Add field move commands
      if !pkmn.egg?
        insert_index = ($DEBUG) ? 2 : 1
        pkmn.moves.each_with_index do |move, i|
          next if !HiddenMoveHandlers.hasHandler(move.id) &&
                  ![:MILKDRINK, :SOFTBOILED].include?(move.id)
          command_list.insert(insert_index, [move.name, 1])
          commands.insert(insert_index, i)
          insert_index += 1
        end
      end
      # Choose a menu option
      choice = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), command_list)
      next if choice < 0 || choice >= commands.length
      # Effect of chosen menu option
      case commands[choice]
      when Hash   # Option defined via a MenuHandler below
        commands[choice]["effect"].call(self, @party, party_idx)
      when Integer   # Hidden move's index
        move = pkmn.moves[commands[choice]]
        if [:MILKDRINK, :SOFTBOILED].include?(move.id)
          amt = [(pkmn.totalhp / 5).floor, 1].max
          if pkmn.hp <= amt
            pbDisplay(_INTL("Not enough HP..."))
            next
          end
          @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          old_party_idx = party_idx
          loop do
            @scene.pbPreSelect(old_party_idx)
            party_idx = @scene.pbChoosePokemon(true, party_idx)
            break if party_idx < 0
            newpkmn = @party[party_idx]
            movename = move.name
            if party_idx == old_party_idx
              pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
            elsif newpkmn.egg?
              pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
            elsif newpkmn.fainted? || newpkmn.hp == newpkmn.totalhp
              pbDisplay(_INTL("{1} can't be used on that Pokémon.", movename))
            else
              pkmn.hp -= amt
              hpgain = pbItemRestoreHP(newpkmn, amt)
              @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", newpkmn.name, hpgain))
              pbRefresh
            end
            break if pkmn.hp <= amt
          end
          @scene.pbSelect(old_party_idx)
          pbRefresh
        elsif pbCanUseHiddenMove?(pkmn, move.id)
          if pbConfirmUseHiddenMove(pkmn, move.id)
            @scene.pbEndScene
            if move.id == :FLY
              ret = pbBetterRegionMap(-1, true, true)
              if ret
                $game_temp.fly_destination = ret
                return [pkmn, move.id]
              end
              @scene.pbStartScene(
                @party, (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel.")
              )
              next
            end
            return [pkmn, move.id]
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

def pbFindEncounter(enc_types, species)
  return false if !enc_types
  enc_types.each_value do |slots|
    next if !slots
    slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
  end
  return false
end

def calculatePointsAndCenter(mapwidth)
  # Fill the array "points" with all squares of the region map in which the
  # species can be found
  points = []
  minxy = [nil, nil] # top-leftmost tile
  maxxy = [nil, nil] # bottom-rightmost tile 
  GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
    next if !pbFindEncounter(enc_data.types, @species)   # Species isn't in encounter table
    # Get the map belonging to the encounter table
    map_metadata = GameData::MapMetadata.try_get(enc_data.map)
    next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
    mappos = map_metadata.town_map_position
    next if mappos[0] != @region   # Map isn't in the region being shown
    # Get the size and shape of the map in the Town Map
    mapsize = map_metadata.town_map_size
    if mapsize && mapsize[0] > 0
      sqwidth  = mapsize[0]
      sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
      for i in 0...sqwidth
        for j in 0...sqheight
          if mapsize[1][i + j * sqwidth, 1].to_i > 0
            # work out the upper-leftmost and lower-rightmost tiles
            minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1]+i) ? mappos[1]+i : minxy[0]
            minxy[1] = (minxy[1] == nil || minxy[1] > mappos[2]+j) ? mappos[2]+j : minxy[1]
            maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1]+i) ? mappos[1]+i : maxxy[0]
            maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2]+j) ? mappos[2]+j : maxxy[1]
            points[mappos[1] + i + (mappos[2] + j) * mapwidth] = true
          end
        end
      end
    else
      # work out the upper-leftmost and lower-rightmost tiles
      minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1]) ? mappos[1] : minxy[0]
      minxy[1] = minxy[1] == nil || minxy[1] > mappos[2] ? mappos[2] : minxy[1]
      maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1]) ? mappos[1] : maxxy[0]
      maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2]) ? mappos[2] : maxxy[1]
      points[mappos[1] + mappos[2] * mapwidth] = true
    end
  end
  return [points, minxy, maxxy]
end

class PokemonReadyMenu
  def pbStartReadyMenu(moves, items)
    commands = [[], []]   # Moves, items
    moves.each do |i|
      commands[0].push([i[0], GameData::Move.get(i[0]).name, true, i[1]])
    end
    commands[0].sort! { |a, b| a[1] <=> b[1] }
    items.each do |i|
      commands[1].push([i, GameData::Item.get(i).name, false])
    end
    commands[1].sort! { |a, b| a[1] <=> b[1] }
    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      break if command == -1
      if command[0] == 0   # Use a move
        move = commands[0][command[1]][0]
        user = $player.party[commands[0][command[1]][3]]
        if move == :FLY
          ret = nil
          pbFadeOutInWithUpdate(99999, @scene.sprites) {
            pbHideMenu
            ret = pbBetterRegionMap(-1, true, true)
            pbShowMenu if !ret
          }
          if ret
            $game_temp.fly_destination = ret
            $game_temp.in_menu = false
            pbUseHiddenMove(user, move)
            break
          end
        else
          pbHideMenu
          if pbConfirmUseHiddenMove(user, move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user, move)
            break
          else
            pbShowMenu
          end
        end
      else   # Use an item
        item = commands[1][command[1]][0]
        pbHideMenu
        if ItemHandlers.triggerConfirmUseInField(item)
          $game_temp.in_menu = false
          break if pbUseKeyItemInField(item)
          $game_temp.in_menu = true
        end
      end
      pbShowMenu
    end
    @scene.pbEndScene
  end
end

class PokemonPokedexInfo_Scene
  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    @sprites["areahighlight"].bitmap.clear
    
    mapwidth = @sprites["areamap"].bitmap.width/BetterRegionMap::TileWidth
    data = calculatePointsAndCenter(mapwidth)

    points = data[0]
    minxy = data[1]
    maxxy = data[2]
    
    # Draw coloured squares on each square of the region map with a nest
    pointcolor   = Color.new(0,248,248)
    pointcolorhl = Color.new(192,248,248)
    sqwidth = BetterRegionMap::TileWidth
    sqheight = BetterRegionMap::TileWidth
    
    
    # Center the window on the center of visible areas
    if minxy[0] != nil && maxxy[0] != nil
      center_x = ((minxy[0]+maxxy[0])/2).round * sqwidth
      center_y = ((minxy[1]+maxxy[1])/2).round * sqheight - 40
    else
      center_x = Settings::SCREEN_WIDTH/2
      center_y = Settings::SCREEN_HEIGHT/2 - 40
    end
    
    windowminx = -1 * (@sprites["areamap"].bmp.width - Settings::SCREEN_WIDTH + 16)
    windowminy = -1 * (@sprites["areamap"].bmp.height - Settings::SCREEN_HEIGHT + 16)
    
    if center_x > (Settings::SCREEN_WIDTH / 2)
      @sprites["areamap"].x = (480 / 2 ) - center_x
      if (@sprites["areamap"].x < windowminx)
        @sprites["areamap"].x = windowminx
      end     
    else
      @sprites["areamap"].x = windowminx
    end
    if center_y > (Settings::SCREEN_HEIGHT / 2)
      @sprites["areamap"].y = (320 / 2 ) - center_y
      if @sprites["areamap"].y < windowminy
        @sprites["areamap"].y = windowminy
      end   
    else
      @sprites["areamap"].y = windowminy
    end
    
    for j in 0...points.length
      if points[j]
        x = (j%mapwidth)*sqwidth
        x += @sprites["areamap"].x
        y = (j/mapwidth)*sqheight
        y += @sprites["areamap"].y - 8
        @sprites["areahighlight"].bitmap.fill_rect(x,y,sqwidth,sqheight,pointcolor)
        if j-mapwidth<0 || !points[j-mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y-2,sqwidth,2,pointcolorhl)
        end
        if j+mapwidth>=points.length || !points[j+mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y+sqheight,sqwidth,2,pointcolorhl)
        end
        if j%mapwidth==0 || !points[j-1]
          @sprites["areahighlight"].bitmap.fill_rect(x-2,y,2,sqheight,pointcolorhl)
        end
        if (j+1)%mapwidth==0 || !points[j+1]
          @sprites["areahighlight"].bitmap.fill_rect(x+sqwidth,y,2,sqheight,pointcolorhl)
        end
      end
    end
    
    # Set the text
    textpos = []
    if points.length==0
      pbDrawImagePositions(overlay,[
         [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"),108,188]
      ])
      textpos.push([_INTL("Area unknown"),Graphics.width/2,Graphics.height/2,2,base,shadow])
    end
    textpos.push([pbGetMessage(MessageTypes::RegionNames,@region),414,50,2,base,shadow])
    textpos.push([_INTL("{1}'s area",GameData::Species.get(@species).name),
       Graphics.width/2,358,2,base,shadow])
       
    textpos.push([_INTL("Full view"),Graphics.width/2,310,2,base,shadow])
    pbDrawTextPositions(overlay,textpos)
  end
end

class PokemonPokedexInfo_Scene
  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCrySpecies(@species,@form) if @page==1
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        if @page==2   # Area
          pbBetterRegionMap(@region,false,false,false,@species)
        elsif @page==3   # Forms
          if @available.length>1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end
end
                                          