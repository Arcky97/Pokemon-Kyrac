#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for bugs in battle code in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed Heavy Ball's catch rate calculation being inaccurate.
#===============================================================================
Battle::PokeBallEffects::ModifyCatchRate.add(:HEAVYBALL, proc { |ball, catchRate, battle, battler|
  next 0 if catchRate == 0
  weight = battler.pbWeight
  if Settings::NEW_POKE_BALL_CATCH_RATES
    if weight >= 3000
      catchRate += 30
    elsif weight >= 2000
      catchRate += 20
    elsif weight < 1000
      catchRate -= 20
    end
  else
    if weight >= 4096
      catchRate += 40
    elsif weight >= 3072
      catchRate += 30
    elsif weight >= 2048
      catchRate += 20
    else
      catchRate -= 20
    end
  end
  next catchRate.clamp(1, 255)
})

#===============================================================================
# Added Obstruct to the blacklists of Assist and Copycat.
#===============================================================================
class Battle::Move::UseRandomMoveFromUserParty < Battle::Move
  alias __hotfixes__initialize initialize
  def initialize(battle, move)
    __hotfixes__initialize(battle, move)
    @moveBlacklist.push("ProtectUserFromDamagingMovesObstruct")
  end
end

class Battle::Move::UseLastMoveUsed < Battle::Move
  alias __hotfixes__initialize initialize
  def initialize(battle, move)
    __hotfixes__initialize(battle, move)
    @moveBlacklist.push("ProtectUserFromDamagingMovesObstruct")
  end
end

module Battle::CatchAndStoreMixin
  def pbStorePokemon(pkmn)
    # Nickname the Pokémon (unless it's a Shadow Pokémon)
    if !pkmn.shadowPokemon?
      if $PokemonSystem.givenicknames == 0 &&
         pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
        pkmn.name = nickname
      end
    end
    # Store the Pokémon
    if pbPlayer.party_full? && (@sendToBoxes == 0 || @sendToBoxes == 2)   # Ask/must add to party
      cmds = [_INTL("Add to your party"),
              _INTL("Send to a Box"),
              _INTL("See {1}'s summary", pkmn.name),
              _INTL("Check party")]
      cmds.delete_at(1) if @sendToBoxes == 2
      loop do
        cmd = pbShowCommands(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
        break if cmd == 99   # Cancelling = send to a Box
        cmd += 1 if cmd >= 1 && @sendToBoxes == 2
        case cmd
        when 0   # Add to your party
          pbDisplay(_INTL("Choose a Pokémon in your party to send to your Boxes."))
          party_index = -1
          @scene.pbPartyScreen(0, (@sendToBoxes != 2), 1) { |idxParty, _partyScene|
            party_index = idxParty
            next true
          }
          next if party_index < 0   # Cancelled
          party_size = pbPlayer.party.length
          # Send chosen Pokémon to storage
          # NOTE: This doesn't work properly if you catch multiple Pokémon in
          #       the same battle, because the code below doesn't alter the
          #       contents of pbParty(0), only pbPlayer.party. This means that
          #       viewing the party in battle after replacing a party Pokémon
          #       with a caught one (which is possible if you've caught a second
          #       Pokémon) will not show the first caught Pokémon in the party
          #       but will still show the boxed Pokémon in the party. Correcting
          #       this would take a surprising amount of code, and it's very
          #       unlikely to be needed anyway, so I'm ignoring it for now.
          send_pkmn = pbPlayer.party[party_index]
          stored_box = @peer.pbStorePokemon(pbPlayer, send_pkmn)
          pbPlayer.party.delete_at(party_index)
          box_name = @peer.pbBoxName(stored_box)
          pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
          # Rearrange all remembered properties of party Pokémon
          (party_index...party_size).each do |idx|
            if idx < party_size - 1
              @initialItems[0][idx] = @initialItems[0][idx + 1]
              $game_temp.party_levels_before_battle[idx] = $game_temp.party_levels_before_battle[idx + 1]
              $game_temp.party_critical_hits_dealt[idx] = $game_temp.party_critical_hits_dealt[idx + 1]
              $game_temp.party_direct_damage_taken[idx] = $game_temp.party_direct_damage_taken[idx + 1]
            else
              @initialItems[0][idx] = nil
              $game_temp.party_levels_before_battle[idx] = nil
              $game_temp.party_critical_hits_dealt[idx] = nil
              $game_temp.party_direct_damage_taken[idx] = nil
            end
          end
          break
        when 1   # Send to a Box
          break
        when 2   # See X's summary
          pbFadeOutIn {
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([pkmn], 0)
          }
        when 3   # Check party
          @scene.pbPartyScreen(0, true, 2)
        end
      end
    end
    # Store as normal (add to party if there's space, or send to a Box if not)
    stored_box = @peer.pbStorePokemon(pbPlayer, pkmn)
    if stored_box < 0
      pbDisplayPaused(_INTL("{1} has been added to your party.", pkmn.name))
      @initialItems[0][pbPlayer.party.length - 1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    box_name = @peer.pbBoxName(stored_box)
    pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
  end
end

#===============================================================================
# Fixed typo in Grassy Glide's effect.
#===============================================================================
class Battle::Move::HigherPriorityInGrassyTerrain < Battle::Move
  def pbPriority(user)
    ret = super
    ret += 1 if @battle.field.terrain == :Grassy && user.affectedByTerrain?
    return ret
  end
end
