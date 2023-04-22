#===============================================================================
# "Autosave Feature v20"
# By Caruban
#-------------------------------------------------------------------------------
# With this plugin, the game will be saved after player catching a Pokemon
# or when transferred into another map.
# Except : 
#  - Transferring between 2 indoor maps
#  - Transferring between 2 connected maps
#  - Transferring while doing the safari game
#  - Transferring while doing a bug catching contest
#  - Transferring while doing a battle challenge
#
# This plugin can be turned off/on temporary by using this script
# pbSetDisableAutosave = value (true or false)
# 
# or from the game options permanently.
#=============================================================================== 
# System and Temp Variables
#===============================================================================
class Game_Temp
  attr_accessor :nextFrameAutosave
  attr_accessor :disableAutosave
  
  def nextFrameAutosave
    @nextFrameAutosave = false if !@nextFrameAutosave
    return @nextFrameAutosave
  end
  def disableAutosave
    @disableAutosave = false if !@disableAutosave
    return @disableAutosave
  end
end

class PokemonSystem
  attr_accessor :autosave
  def autosave
    # Autosave (0=on, 1=off)
    @autosave = 0 if !@autosave
    return @autosave
  end
end
#===============================================================================
# Game Option
#===============================================================================
MenuHandlers.add(:options_menu, :autosave, {
  "name"        => _INTL("Autosave"),
  "order"       => 81,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether your game saved automatically or not."),
  "get_proc"    => proc { next $PokemonSystem.autosave },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.autosave = value }
})
#===============================================================================
# Script
#===============================================================================
def pbCanAutosave?
  return $PokemonSystem.autosave==0 && !$game_temp.disableAutosave
end

def pbSetDisableAutosave=(value)
  $game_temp.disableAutosave = value
end

def pbAutosave(scene = nil)
  scene = $scene if !scene
  return if $PokemonSystem.autosave!=0
  if !pbInSafari? && !pbInBugContest? && !pbBattleChallenge.pbInChallenge?
    scene.spriteset.addUserSprite(Autosave.new)
    Game.save
  end
end

# Check if the map are connected
EventHandlers.add(:on_enter_map, :autosave,
  proc { |old_map_id|   # previous map ID, is 0 if no map ID
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    old_map_metadata = GameData::MapMetadata.try_get(old_map_id)
    if old_map_id>0 && !$map_factory.areConnected?($game_map.map_id, old_map_id) && 
      map_metadata && old_map_metadata && (map_metadata.outdoor_map || old_map_metadata.outdoor_map)
      $game_temp.nextFrameAutosave = true 
    end
  }
  )

# On frame update after Walk in or out of a building
EventHandlers.add(:on_frame_update, :autosave,
  proc {
    next if !pbCanAutosave?
    next if !$game_temp.nextFrameAutosave
    next if $game_temp.in_menu || $game_temp.in_battle || $game_player.move_route_forcing ||
            $game_temp.message_window_showing || pbMapInterpreterRunning?
    pbAutosave
    $game_temp.nextFrameAutosave = false
  }
)

# Autosave when caught a pokemon
EventHandlers.add(:on_wild_battle_end, :autosave_catchpkm,
  proc { |species, level, decision|
    next if !pbCanAutosave?
    $game_temp.nextFrameAutosave = true  if decision==4
  }
)

class Autosave
  def initialize
    @bitmapsprite = BitmapSprite.new(Graphics.width,Graphics.height,nil)
    @bitmap = @bitmapsprite.bitmap
    pbSetSmallFont(@bitmap)
    text=[["Now Saving...",392,1,0,Color.new(248,248,248),Color.new(97,97,97)]]
    pbDrawTextPositions(@bitmap,text)
    @bitmapsprite.visible = true
    @frame = 0
    @looptime = 0
    @i = 1
    @currentmap = $game_map.map_id
  end
  def pbStart
    @bitmapsprite.visible = true
    @i = -1
  end
  def isStart?
    return @start
  end
  def disposed?
    @bitmapsprite.disposed?
  end
  def update
    if @currentmap != $game_map.map_id
      @bitmapsprite.dispose
      return
    end
    if @frame > Graphics.frame_rate / 2
      if @looptime == 3
        @bitmapsprite.dispose
        @frame = 0
      else
        @looptime += 1
        @frame = 0
        @i *= -1
      end
    else
      @frame += 1
      @bitmapsprite.opacity += 10 * @i
    end
  end
  def dispose
    @bitmapsprite.dispose if @bitmapsprite
  end
end