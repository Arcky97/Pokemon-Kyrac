module FollowingPkmn
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon event and corresponding
  # Follower Data
  #-----------------------------------------------------------------------------
  def self.get
    return nil if !FollowingPkmn.can_check?
    $game_temp.followers.each_follower do |event, follower|
      next if !follower.following_pkmn?
      return [event, follower]
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon event
  #-----------------------------------------------------------------------------
  def self.get_event
    return nil if !FollowingPkmn.can_check?
    ret = FollowingPkmn.get
    return ret.is_a?(Array) ? ret[0] : nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon FollowerData
  #-----------------------------------------------------------------------------
  def self.get_data
    return nil if !FollowingPkmn.can_check?
    ret = FollowingPkmn.get
    return ret.is_a?(Array) ? ret[1] : nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Pokemon Object of the Following Pokemon
  #-----------------------------------------------------------------------------
  def self.get_pokemon
    return nil if !FollowingPkmn.can_check?
    return $player.first_able_pokemon
  end
  #-----------------------------------------------------------------------------
  # Script Command for checking whether the current follower is airborne
  #-----------------------------------------------------------------------------
  def self.airborne_follower?
    return false if !FollowingPkmn.can_check?
    pkmn = FollowingPkmn.get_pokemon
    return false if !pkmn
    return true if pkmn.hasType?(:FLYING)
    return true if pkmn.hasAbility?(:LEVITATE)
    return true if FollowingPkmn::SURFING_FOLLOWERS_EXCEPTIONS.any? { |s| s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}" }
    return false
  end
  #-----------------------------------------------------------------------------
  # Forcefully refresh Following Pokemon sprite with animation (if specified)
  #-----------------------------------------------------------------------------
  def self.refresh(anim = false)
    return if !FollowingPkmn.can_check?
    FollowingPkmn.remove_sprite
    first_pkmn = FollowingPkmn.get_pokemon
    return if !first_pkmn
    FollowingPkmn.refresh_internal
    ret = FollowingPkmn.active?
    case first_pkmn.poke_ball
    when :CHERISHBALL
      ball = [:ANIMATION_COME_OUT_CHERISHBALL, :ANIMATION_COME_IN_CHERISHBALL]
    when :DIVEBALL 
      ball = [:ANIMATION_COME_OUT_DIVEBALL, :ANIMATION_COME_IN_DIVEBALL]
    when :DREAMBALL
      ball = [:ANIAMTION_COME_OUT_DREAMBALL, :ANIMATION_COME_IN_DREAMBALL]
    when :DUSKBALL
      ball = [:ANIMATION_COME_OUT_DUSKBALL, :ANIMATION_COME_IN_DUSKBALL]
    when :FASTBALL 
      ball = [:ANIMATION_COME_OUT_FASTBALL, :ANIMATION_COME_IN_FASTBALL]
    when :FRIENDBALL
      ball = [:ANIMATION_COME_OUT_FRIENDBALL, :ANIMATION_COME_IN_FRIENDBALL] 
    when :GREATBALL
      ball = [:ANIMATION_COME_OUT_GREATBALL, :ANIMATION_COME_IN_GREATBALL] 
    when :HEALBALL 
      ball = [:ANIMATION_COME_OUT_HEALBALL, :ANIMATION_COME_IN_HEALBALL] 
    when :HEAVYBALL
      ball = [:ANIMATION_COME_OUT_HEAVYBALL, :ANIMATION_COME_IN_HEAVYBALL] 
    when :LEVELBALL
      ball = [:ANIMATION_COME_OUT_LEVELBALL, :ANIMATION_COME_IN_LEVELBALL] 
    when :LOVEBALL 
      ball = [:ANIMATION_COME_OUT_LOVEBALL, :ANIMATION_COME_IN_LOVEBALL] 
    when :LUREBALL 
      ball = [:ANIMATION_COME_OUT_LUREBALL, :ANIMATION_COME_IN_LUREBALL]
    when :LUXURYBALL
      ball = [:ANIMATION_COME_OUT_LUXURYBALL, :ANIMATION_COME_IN_LUXURYBALL] 
    when :MASTERBALL
      ball = [:ANIMATION_COME_OUT_MASTERBALL, :ANIMATION_COME_IN_MASTERBALL] 
    when :MOONBALL 
      ball = [:ANIMTION_COME_OUT_MOONBALL, :ANIMATION_COME_IN_MOONBALL]
    when :NESTBALL 
      ball = [:ANIMATION_COME_OUT_NESTBALL, :ANIMATION_COME_IN_NESTBALL]
    when :NETBALL 
      ball = [:ANIMATION_COME_OUT_NETBALL, :ANIMATION_COME_IN_NETBALL]
    when :PREMIERBALL
      ball = [:ANIMATION_COME_OUT_PREMIERBALL, :ANIMATION_COME_IN_PREMIERBALL] 
    when :QUICKBALL
      ball = [:ANIMATION_COME_OUT_QUICKBALL, :ANIMATION_COME_IN_QUICKBALL] 
    when :REPEATBALL
      ball = [:ANIMATION_COME_OUT_REPEATBALL, :ANIMATION_COME_IN_REPEATBALL] 
    when :SAFARIBALL
      ball = [:ANIMATION_COME_OUT_SAFARIBALL, :ANIMATION_COME_IN_SAFARIBALL] 
    when :SPORTBALL
      ball = [:ANIMATION_COME_OUT_SPORTBALL, :ANIMATION_COME_IN_SPORTBALL] 
    when :TIMERBALL
      ball = [:ANIMATION_COME_OUT_TIMERBALL, :ANIMATION_COME_IN_TIMERBALL] 
    when :ULTRABALL
      ball = [:ANIMATION_COME_OUT_ULTRABALL, :ANIMATION_COME_IN_ULTRABALL] 
    else  
      ball = [:ANIMATION_COME_OUT_POKEBALL, :ANIMATION_COME_IN_POKEBALL]
    end
    if anim
      event = FollowingPkmn.get_event
      anim_name = ret ? ball[0] : ball[1] #:ANIMATION_COME_OUT_CHERISHBALL : :ANIMATION_COME_IN_CHERISHBALL
      anim_id   = nil
      anim_id   = FollowingPkmn.const_get(anim_name) if FollowingPkmn.const_defined?(anim_name)
      if event && anim_id
        $scene.spriteset.addUserAnimation(anim_id, event.x, event.y, false, 1)
        pbMoveRoute($game_player, [PBMoveRoute::Wait, 2])
        pbWait(Graphics.frame_rate/5)
      end
    end
    FollowingPkmn.change_sprite(first_pkmn) if ret
    FollowingPkmn.move_route([(ret ? PBMoveRoute::StepAnimeOn : PBMoveRoute::StepAnimeOff)]) if FollowingPkmn::ALWAYS_ANIMATE
    $PokemonGlobal.time_taken = 0 if !ret
    return ret
  end
  #-----------------------------------------------------------------------------
  # Forcefully refresh Following Pokemon sprite with animation (if specified)
  #-----------------------------------------------------------------------------
  def self.remove_sprite
    FollowingPkmn.get_event&.character_name = ""
    FollowingPkmn.get_data&.character_name  = ""
    FollowingPkmn.get_event&.character_hue  = 0
    FollowingPkmn.get_data&.character_hue   = 0
  end
  #-----------------------------------------------------------------------------
  # Set the Following Pokemon sprite to a different Pokemon
  #-----------------------------------------------------------------------------
  def self.change_sprite(pkmn)
    shiny = pkmn.shiny?
    shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.superShiny?)
    fname = GameData::Species.ow_sprite_filename(pkmn.species, pkmn.form,
      pkmn.gender, shiny, pkmn.shadow)
    fname.gsub!("Graphics/Characters/", "")
    FollowingPkmn.get_event&.character_name = fname
    FollowingPkmn.get_data&.character_name  = fname
    if FollowingPkmn.get_event&.move_route_forcing
      hue = pkmn.respond_to?(:superHue) && pkmn.superShiny? ? pkmn.superHue : 0
      FollowingPkmn.get_event&.character_hue  = hue
      FollowingPkmn.get_data&.character_hue   = hue
    end
  end
  #-----------------------------------------------------------------------------
end
