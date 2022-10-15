#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for miscellaneous bugs in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

Essentials::ERROR_TEXT += "[v20.1 Hotfixes 1.0.2]\r\n"

#===============================================================================
# Fixed the "See ya!" option in the PC menu not working properly.
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"      => proc {
    next ($player.seen_storage_creator) ? _INTL("{1}'s PC", pbGetStorageCreator) : _INTL("Someone's PC")
  },
  "order"     => 10,
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organize Boxes"),
          _INTL("Withdraw Pokémon"),
          _INTL("Deposit Pokémon"),
          _INTL("See ya!")],
         [_INTL("Organize the Pokémon in Boxes and in your party."),
          _INTL("Move Pokémon stored in Boxes to your party."),
          _INTL("Store Pokémon in your party in Boxes."),
          _INTL("Return to the previous menu.")], -1, command)
      break if command < 0
      case command
      when 0   # Organize
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
        }
      when 1   # Withdraw
        if $PokemonStorage.party_full?
          pbMessage(_INTL("Your party is full!"))
          next
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(1)
        }
      when 2   # Deposit
        count = 0
        $PokemonStorage.party.each do |p|
          count += 1 if p && !p.egg? && p.hp > 0
        end
        if count <= 1
          pbMessage(_INTL("Can't deposit the last Pokémon!"))
          next
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(2)
        }
      else
        break
      end
    end
    next false
  }
})

#===============================================================================
# Fixed Pokémon icons sometimes disappearing in Pokémon storage screen.
#===============================================================================
class PokemonBoxPartySprite < Sprite
  alias __hotfixes__refresh refresh
  def refresh
    __hotfixes__refresh
    Settings::MAX_PARTY_SIZE.times do |j|
      sprite = @pokemonsprites[j]
      sprite.z = 1 if sprite && !sprite.disposed?
    end
  end
end

class PokemonBoxSprite < Sprite
  alias __hotfixes__refresh refresh
  def refresh
    __hotfixes__refresh
    PokemonBox::BOX_HEIGHT.times do |j|
      PokemonBox::BOX_WIDTH.times do |k|
        sprite = @pokemonsprites[(j * PokemonBox::BOX_WIDTH) + k]
        sprite.z = 1 if sprite && !sprite.disposed?
      end
    end
  end
end

#===============================================================================
# Fixed playing the credits/changing $scene leaving a ghost image of the old map
# behind.
#===============================================================================
class Scene_Map
  def dispose
    disposeSpritesets
    @map_renderer.dispose
    @map_renderer = nil
    @spritesetGlobal.dispose
    @spritesetGlobal = nil
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    dispose
    if $game_temp.title_screen_calling
      Graphics.transition
      Graphics.freeze
    end
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.dispose
  visibleObjects = pbHideVisibleObjects
  Graphics.transition
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition
  Graphics.freeze
  $scene = oldscene
  $scene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition
end

#===============================================================================
# Fixed Rare Candy not reviving a fainted Shedinja.
#===============================================================================
def pbChangeLevel(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s level remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s level remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  pkmn.level = new_level
  pkmn.calc_stats
  pkmn.hp = 1 if new_level > old_level && pkmn.species_data.base_stats[:HP] == 1
  scene.pbRefresh
  if old_level > new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else
    pkmn.changeHappiness("vitamin")
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
  end
end

#===============================================================================
# Fixed fainted Pokémon reviving if they evolve.
#===============================================================================
class PokemonEvolutionScene
  def pbEvolutionSuccess
    $stats.evolution_count += 1
    # Play cry of evolved species
    frames = (GameData::Species.cry_length(@newspecies, @pokemon.form) * Graphics.frame_rate).ceil
    Pokemon.play_cry(@newspecies, @pokemon.form)
    (frames + 4).times do
      Graphics.update
      pbUpdate
    end
    pbBGMStop
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = GameData::Species.get(@newspecies).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
                           @pokemon.name, newspeciesname)) { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    was_fainted = @pokemon.fainted?
    @pokemon.species = @newspecies
    @pokemon.hp = 0 if was_fainted
    @pokemon.calc_stats
    @pokemon.ready_to_evolve = false
    # See and own evolved species
    was_owned = $player.owned?(@newspecies)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@newspecies)
    moves_to_learn = []
    movelist = @pokemon.getMoveList
    movelist.each do |i|
      next if i[0] != 0 && i[0] != @pokemon.level   # 0 is "learn upon evolution"
      moves_to_learn.push(i[1])
    end
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned && $player.has_pokedex
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", newspeciesname)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
        @sprites["msgwindow"].text = "" if moves_to_learn.length > 0
        pbEndScreen(false) if moves_to_learn.length == 0
      }
    end
    # Learn moves upon evolution for evolved species
    moves_to_learn.each do |move|
      pbLearnMove(@pokemon, move, true) { pbUpdate }
    end
  end
end

#===============================================================================
# Fixed some special battle intro animations not playing when they should.
#===============================================================================
SpecialBattleIntroAnimations.get("vs_trainer_animation")[2] = proc { |battle_type, foe, location|   # Condition
  next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
  tr_type = foe[0].trainer_type
  next pbResolveBitmap("Graphics/Transitions/hgss_vs_#{tr_type}") &&
       pbResolveBitmap("Graphics/Transitions/hgss_vsBar_#{tr_type}")
}

SpecialBattleIntroAnimations.get("vs_elite_four_animation")[2] = proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsE4_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsE4Bar_#{tr_type}")
  }

SpecialBattleIntroAnimations.get("alternate_vs_trainer_animation")[2] = proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsTrainer_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsBar_#{tr_type}")
  }

#===============================================================================
# Fixed SystemStackError when two events on connected maps have their backs to
# the other map.
#===============================================================================
class Game_Character
  def calculate_bush_depth
    if @tile_id > 0 || @always_on_top || jumping?
      @bush_depth = 0
      return
    end
    this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $map_factory&.getNewMap(@x, @y, self.map.map_id)
    if this_map && this_map[0].deepBush?(this_map[1], this_map[2])
      xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
      ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
      if moving?
        behind_map = (self.map.valid?(xbehind, ybehind)) ? [self.map, xbehind, ybehind] : $map_factory&.getNewMap(xbehind, ybehind, self.map.map_id)
        @bush_depth = Game_Map::TILE_HEIGHT if behind_map[0].deepBush?(behind_map[1], behind_map[2])
      else
        @bush_depth = Game_Map::TILE_HEIGHT
      end
    elsif this_map && this_map[0].bush?(this_map[1], this_map[2]) && !moving?
      @bush_depth = 12
    else
      @bush_depth = 0
    end
  end
end

#===============================================================================
# Fixed error when getting terrain tag when the player moves between connected
# maps.
#===============================================================================
class Game_Player < Game_Character
  def pbTerrainTag(countBridge = false)
    return $map_factory.getTerrainTagFromCoords(self.map.map_id, @x, @y, countBridge) if $map_factory
    return $game_map.terrain_tag(@x, @y, countBridge)
  end
end
