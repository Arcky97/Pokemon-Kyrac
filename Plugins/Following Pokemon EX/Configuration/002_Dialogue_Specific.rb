#-------------------------------------------------------------------------------
# This Function will make sure the correct bubble is displayed when this method is called.
#-------------------------------------------------------------------------------
def showEmote(emote)
  case emote
  when /Happy/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
  when /Angry/i    
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
  when /Mad/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MAD)
  when /Sad/i
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_SAD)
  when /Heart/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HEART)
  when /Music/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
  when /Smile/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_SMILE)
  when /Thinking/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
  when /Exclam/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_EXCLAM)
  when /Question/i   
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_QUESTION)
  end
  pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
end

#-------------------------------------------------------------------------------
# Specific Dialogues for Indoor Maps.
# Dialogues for Specific Pokémon are defined like this: when :SPECIES. 
# You can add as many as you want if you want other species to have different dialogues on the same location. 
# (I would group the evolutions in the same when condition to keep the code a bit shorter and more easy to edit.)
#-------------------------------------------------------------------------------

EventHandlers.add(:following_pkmn_talk, :indoormaps, proc { |pkmn, _random_val, pkmnName, playerName|
  case $game_map.name #Checks the Map Name
  when /#{$player.name}'s house/i #The Map Name includes "Player's house" in it's name (case insensitive)
    case pkmn.species #Checks the Follower Species
    when :GROWLITHE, :ARCANINE #The Follower is Growlithe or Arcanine 
      case $player.badge_count #Checks how many badges the player has.
      when 0, 1, 2 #The Player has 0, 1 or 2 Badges.
        showEmote("Music") #Call this function to display the Bubble of the Emotion you want the Follower to show. (It's case insensitive so if you write music, Music, MusiC, MUSIC, etc. It doesn't matter at all)
        messages = [
          _INTL("{3}*Gets excited to start exporing the Kyrac Region*"),
          _INTL("{4}{1} seems to be excited to start our adventure in the Kyrac Region")
        ]
        messages.push(_INTL("{4}{1} barks at mom meaning to say goodbye.")) if $game_variables[62] == "#{$player.name}'s House F1" #This Dialogue will be added to messages if the Game Variable 62 is equal to "Player's House F1"
      when 3, 4 #The Player has 3 or 4 Badges.
        showEmote("Happy")
        messages = [
          _INTL("{4}{1} is happy to be home again."),
          _INTL("{4}{1} seems excited to finally sleep in our room again.")
        ]
      when 5, 6, 7 #The Player has 5, 6 or 7 Badges
        showEmote("Question")
        messages = [
          _INTL("{3}*looks confused at {2} for why we returned home."),
        ]
      when 8, 9, 10, 11 #The Player has 8, 9, 10 or 11 Badges.
      
      when 12, 13, 14 #The Player has 12, 13 or 14 Badges.

      when 15, 16 #The Player has 15 or 16 Badges.

      end
    else #The Follower is any Pokémon except Growlithe or Arcanine
      messages = [
        _INTL("{3}*Notices {2}'s mom is near*"),
        _INTL("{4}{1} seems to want to settle down at home."),
        _INTL("{4}{1} is sniffing around the room.")
      ]
    end
  when /Rival's house/i #The Map Name includes "Rival's house" (case insensitive)
    case pkmn.species
    when :GROWLITHE
      showEmote("Sad")
      messages = [
        _INTL("{1}doesn't feel at eas in the Rival's house!")
      ]
    else
      showEmote("Exclam")
      messages = [
        _INTL("{1}seems want to fight the Rivals all at once")
      ]
    end
  when /Proffesor's lab/i
    if $game_variables[7] == 0 #The Player hasn't chosen a Starter yet.
      showEmote("Happy")
      messages = [
        _INTL("{4}{1} is exited to choose a starter Pokémon."),
        _INTL("{3}*wants you to hurry up and choose a starter*"),
        _INTL("{4}{1} seems to want to be very excited.")
      ]
    elsif $game_self_switches[[24,91,"A"]] #After the Player has chosen a Starter and before the Rival battle.
      showEmote("Exclam")
      messages = [
        _INTL("{4}{1}is exited to fight \\v[45] and \\v[46]."),
        _INTL("{3}*Gets exited for the first battle*"),
        _INTL("{4}{1} is happy to be let out of it's Pokeball.")
      ]
    else #The common Dialogues for any Follower.
      showEmote("Thinking")
      messages = [
        _INTL("{3}*touches some big red button*"),
        _INTL("{4}{1}touched some big red button, oh no!"),
        _INTL("{4}{1}has a cord in its mouth!"),
        _INTL("{3}*Wants to touch the machinery*"),
        _INTL("{4}{1} seems to want to touch the machinery."),
        _INTL("{4}{1} looks happy at Prof. Oak!"),
        _INTL("{3}*Smiles at Prof. Oak*")
      ]
      if $game_variables[47] == 0 #The Game Variable 47 (Region Map Yacht) is 0.
        if pkmn.hp <= (pkmn.totalhp / 4).floor #Pokemon is at Low Health.
          messages.push(
            _INTL("{4}{1}is exhausted from the battle but happy about it's first victory."),
            _INTL("{3}*Wants {2} to go to the Poké Center*")
          )
        elsif pkmn.hp >= (pkmn.totalhp / 4).floor && pkmn.hp <= (pkmn.totalhp / 2).floor #Pokémon is at Medium Health.
          messages.push(
            _INTL("{4}{1} might just have enough energy for another battle.")
          )
        else #Pokémon is at Full or Higher than Medium Health.
          messages.push(
            _INTL("{4}{1} seems to have more than enough energy for another battle."),
            _INTL("{3}*Wants {2} to battle another Trainer*")
          )
          #The following line goes in the condition for Full HP as when the Player lost the battle, their Pokémon get healed. This is also only if the battle is set to canLose.
          messages.push(_INTL("{4}{1} is back at full health and isn't that sad about having lost the battle.")) if  $game_variables[1] != 1 #The Player has lost the First Rival Battle.
        end
      end
    end 
  when /Pokémon League/i
    messages = [
      _INTL("{1}is releasing some strong aura")
    ]
  when /Pokemon Center/i
    messages = [
      _INTL("{1} looks happy to see the nurse."),
      _INTL("{1} looks a little better just being in the Pokémon Center."),
      _INTL("{1} seems fascinated by the healing machinery."),
      _INTL("{1} looks like it wants to take a nap."),
      _INTL("{1} chirped a greeting at the nurse."),
      _INTL("{1} is watching {2} with a playful gaze."),
      _INTL("{1} seems to be completely at ease."),
      _INTL("{1} is making itself comfortable."),
      _INTL("There's a content expression on {1}'s face.")
    ]
  when /Pokemart/i
    messages = [
      _INTL("{4}{1} is looking as it would want to get a present!")
    ]
  when /Evil Team Base/i
    case pkmn.species 
    when :GROWLITHE, :ARCANINE #The Follower is Growlithe or Arcanine.
      messages = [
        _INTL("{1}is howling and feeling scared!")
      ]
    else
      messages = [
        _INTL("")
      ]
    end
  when /Gym/i
    messages = [
      _INTL("{1} looks eager to battle!"),
      _INTL("{1} is looking at {2} with a determined gleam in its' eye."),
      _INTL("{4}{1} is trying to intimidate the other trainers."),
      _INTL("{4}{1} trusts {2} to come up with a winning strategy."),
      _INTL("{4}{1} is keeping an eye on the gym leader."),
      _INTL("{1} is ready to pick a fight with someone."),
      _INTL("{1} looks like it might be preparing for a big showdown!"),
      _INTL("{1} wants to show off how strong it is!"),
      _INTL("{1} is...doing warm-up exercises?"),
      _INTL("{1} is growling quietly in contemplation...")
    ]
  when /Factory/i
    messages = [
      _INTL("")
    ]
  end
  if $game_switches[99] #The Switch 99 is On. (Change this to any number you want.) Used for Random NPC's House.
    case pkmn.species 
    when :PICHU, :PIKACHU, :RAICHU, :RAICHU_1 #The Follower is Pichu, Pikachu, Raichu or Alolan Raichu.
      messages = [
        _INTL("")
      ]
    when :GROWLITHE, :ARCANINE #The Follower is Growlithe or Arcanine.
      messages = [
        _INTL("")
      ]
    else #The Follower is none of the Pokémon stated above.
      messages = [
        _INTL("")
      ]
    end 
  end
  pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
  next true
})

#-------------------------------------------------------------------------------
# Specific Dialogues for the Poké Center and Poké Mart.
# Dialogues for Specific Pokémon are defined like this: when :SPECIES. 
# You can add as many as you want if you want other species to have different dialogues on the same location. 
# (I would group the evolutions in the same when condition to keep the code a bit shorter and more easy to edit.)
#-------------------------------------------------------------------------------

EventHandlers.add(:following_pkmn_talk, :pokecenter, proc { |pkmn, _random_val, pkmnName, playerName|
  if $game_switches[1] #The Game Switch (Blacked out Healed) is On.
    case pkmn.species 
    when :VOLTORB, :ELECTRODE #The Follower is Voltorb or Electrode.
      messages = [
        _INTL("")
      ]
    else #The Follower is none of the Pokémon stated above.
      messages = [
        _INTL("")
      ]
    end
  elsif $game_switches[98] #The Game Switch (Pokémon Healed) is On.
    messages = [
      _INTL("")
    ]
    !$game_switches[98] #If you want to make the Script choose only one time a dialogue after the Follower was healed, then you can turn off the Switch like this.
  elsif $game_switches[97] #The Game Switch (Just Bought Item) is On.
  end
  pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
  next true
})

EventHandlers.add(:following_pkmn_talk, :shiny, proc { |pkmn, _random_val, pkmnName, playerName|
  if pkmn.shiny?
    messages = [
      _INTL("")
    ]
  end 
  pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
  next true
})


EventHandlers.add(:following_pkmn_talk, :status, proc { |pkmn, _random_val, pkmnName, playerName|
  case pkmn.status
  when :POISON
    showEmote("Thinking")
    if pkmn.type == :GROWLITHE #The Follower is Growlithe
      messages = [
        _INTL("Poison courses through your {1}'s veins. It needs immediate treatment!")
      ]
    elsif $bag.has?(:ANTIDOTE) || $bag.has?(:FULLHEAL) || $bag.has?(:PECHABERRY) #The player has an Antidote, Full Heal or Pecha Berry in their bag, it'll use this dialogue unless the Follower is one that is stated above.
      messages = [
        _INTL("Oh no! {1} has been poisoned! Let's use an Antidote!")
      ]
    else #The Follower is none of the Pokémon stated above and the Player does not have any Antidote, Full Heal or Pecha Berry in their bag.
      messages = [
        _INTL("{1} is shivering with the effects of being poisoned.")
      ]
    end
  when :BURN
    showEmote("Thinking")
    if pkmn.type == :GROWLITHE
      messages = [
        _INTL("{1}'s burn looks painful.")
      ]
    elsif $bag.has?(:BURNHEAL)
    else 
      messages = [
        _INTL("{1}'s burn looks painful.")
      ]
    end
  when :FROZEN
    showEmote("Thinking")
    if pkmn.type == :GROWLITHE
      messages = [
        _INTL("Oh no, {1} is frozen solid! It can't move a muscle!"),
        _INTL("{1}'s body is covered in a layer of ice. It's unable to do anything!"),
        _INTL("The freezing cold has turned {1} into a solid ice sculpture. It needs thawing out!"),
        _INTL("Frozen stiff! {1} is encased in ice and can't take any actions."),
        _INTL("")
      ]
    else 
      messages = [
        _INTL("{1} seems very cold. It's frozen solid!")
      ]
    end
  when :SLEEP
    showEmote("Thinking")
    if pkmn.type == :GROWLITHE
      messages = [
        _INTL("{1} seems really tired.")
      ]
    else 
      messages = [
        _INTL("{1} seems really tired.")
      ]
    end
  when :PARALYSIS
    showEmote("Thinking")
    if pkmn.type == :GROWLITHE
      messages = [
        _INTL("{1} is standing still and twitching.")
      ]
    else 
      messages = [
        _INTL("{1} is standing still and twitching.")
      ]
    end
  end
  pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
  next true if pkmn.status != :NONE
})

EventHandlers.add(:following_pkmn_talk, :happiness, proc { |pkmn, _random_val, pkmnName, playerName|
  if pkmn.happiness <= 64 #The Happiness of the Follower is 64 or below.

  elsif pkmn.happiness > 64 && pkmn.happiness < 192 #The Happiness of the Follower is higher than 64 but lower than 192

  else #The Happiness of the Follower is 192 or higher.
  end
})

#-------------------------------------------------------------------------------
# Specific message when the weather is Storm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :storm_weather, proc { |pkmn, _random_val, pkmnName, playerName|
  if :Storm == $game_screen.weather_type
    if pkmn.hasType?(:ELECTRIC)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("The storm seems to be making {1} excited."),
        _INTL("{1} looked up at the sky and shouted loudly!"),
        _INTL("The storm only seems to be energizing {1}!"),
        _INTL("{1} is happily zapping and jumping in circles!"),
        _INTL("The lightning doesn't bother {1} at all.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("The storm seems to be making {1} a bit nervous."),
        _INTL("The lightning startled {1}!"),
        _INTL("The rain doesn't seem to bother {1} much."),
        _INTL("The weather seems to be putting {1} on edge."),
        _INTL("{1} was startled by the lightning and snuggled up to {2}!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Snowy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :snow_weather, proc { |pkmn, _random_val, pkmnName, playerName|
  if :Snow == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the snow fall."),
        _INTL("{1} is thrilled by the snow!"),
        _INTL("{1} is staring up at the sky with a smile."),
        _INTL("The snow seems to have put {1} in a good mood."),
        _INTL("{1} is cheerful because of the cold!")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the snow fall."),
        _INTL("{1} is nipping at the falling snowflakes."),
        _INTL("{1} wants to catch a snowflake in its' mouth."),
        _INTL("{1} is fascinated by the snow."),
        _INTL("{1}'s teeth are chattering!"),
        _INTL("{1} made its body slightly smaller because of the cold...")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Blizzard. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :blizzard_weather, proc { |pkmn, _random_val, pkmnName, playerName|
  if :Blizzard == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the hail fall."),
        _INTL("{1} isn't bothered at all by the hail."),
        _INTL("{1} is staring up at the sky with a smile."),
        _INTL("The hail seems to have put {1} in a good mood."),
        _INTL("{1} is gnawing on a piece of hailstone.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is getting pelted by hail!"),
        _INTL("{1} wants to avoid the hail."),
        _INTL("The hail is hitting {1} painfully."),
        _INTL("{1} looks unhappy."),
        _INTL("{1} is shaking like a leaf!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Sandstorm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :sandstorm_weather, proc { |pkmn, _random_val, pkmnName|
  if :Sandstorm == $game_screen.weather_type
    if [:ROCK, :GROUND].any? { |type| pkmn.hasType?(type) }
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is coated in sand."),
        _INTL("The weather doesn't seem to bother {1} at all!"),
        _INTL("The sand can't slow {1} down!"),
        _INTL("{1} is enjoying the weather.")
      ]
    elsif pkmn.hasType?(:STEEL)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is coated in sand, but doesn't seem to mind."),
        _INTL("{1} seems unbothered by the sandstorm."),
        _INTL("The sand doesn't slow {1} down."),
        _INTL("{1} doesn't seem to mind the weather.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is covered in sand..."),
        _INTL("{1} spat out a mouthful of sand!"),
        _INTL("{1} is squinting through the sandstorm."),
        _INTL("The sand seems to be bothering {1}.")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map has the Forest metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :forest_map, proc { |pkmn, _random_val, pkmnName|
  if $game_map.metadata&.has_flag?("Forest")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    if [:BUG, :GRASS].any? { |type| pkmn.hasType?(type) }
      messages = [
        _INTL("{1} seems highly interested in the trees."),
        _INTL("{1} seems to enjoy the buzzing of the bug Pokémon."),
        _INTL("{1} is jumping around restlessly in the forest.")
      ]
    else
      messages = [
        _INTL("{1} seems highly interested in the trees."),
        _INTL("{1} seems to enjoy the buzzing of the bug Pokémon."),
        _INTL("{1} is jumping around restlessly in the forest."),
        _INTL("{1} is wandering around and listening to the different sounds."),
        _INTL("{1} is munching at the grass."),
        _INTL("{1} is wandering around and enjoying the forest scenery."),
        _INTL("{1} is playing around, plucking bits of grass."),
        _INTL("{1} is staring at the light coming through the trees."),
        _INTL("{1} is playing around with a leaf!"),
        _INTL("{1} seems to be listening to the sound of rustling leaves."),
        _INTL("{1} is standing perfectly still and might be imitating a tree..."),
        _INTL("{1} got tangled in the branches and almost fell down!"),
        _INTL("{1} was surprised when it got hit by a branch!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Rainy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :rainy_weather, proc { |pkmn, _random_val, pkmnName, playerName|
  if [:Rain, :HeavyRain].include?($game_screen.weather_type)
    if pkmn.hasType?(:FIRE) || pkmn.hasType?(:GROUND) || pkmn.hasType?(:ROCK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems very upset the weather."),
        _INTL("{1} is shivering..."),
        _INTL("{1} doesn't seem to like being all wet..."),
        _INTL("{1} keeps trying to shake itself dry..."),
        _INTL("{1} moved closer to {2} for comfort."),
        _INTL("{1} is looking up at the sky and scowling."),
        _INTL("{1} seems to be having difficulty moving its body.")
      ]
    elsif pkmn.hasType?(:WATER) || pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems to be enjoying the weather."),
        _INTL("{1} seems to be happy about the rain!"),
        _INTL("{1} seems to be very surprised that it's raining!"),
        _INTL("{1} beamed happily at {2}!"),
        _INTL("{1} is gazing up at the rainclouds."),
        _INTL("Raindrops keep falling on {1}."),
        _INTL("{1} is looking up with its mouth gaping open.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("{1} looks a bit surprised to see rain."),
        _INTL("{1} keeps trying to shake itself dry."),
        _INTL("The rain doesn't seem to bother {1} much."),
        _INTL("{1} is playing in a puddle!"),
        _INTL("{1} is slipping in the water and almost fell over!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Sunny. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :sunny_weather, proc { |pkmn, _random_val, pkmnName, playerName|
  if :Sun == $game_screen.weather_type
    if pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems pleased to be out in the sunshine."),
        _INTL("{1} is soaking up the sunshine."),
        _INTL("The bright sunlight doesn't seem to bother {1} at all."),
        _INTL("{1} sent a ring-shaped cloud of spores into the air!"),
        _INTL("{1} is stretched out its body and is relaxing in the sunshine."),
        _INTL("{1} is giving off a floral scent.")
      ]
    elsif pkmn.hasType?(:FIRE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems to be happy about the great weather!"),
        _INTL("The bright sunlight doesn't seem to bother {1} at all."),
        _INTL("{1} looks thrilled by the sunshine!"),
        _INTL("{1} blew out a fireball."),
        _INTL("{1} is breathing out fire!"),
        _INTL("{1} is hot and cheerful!")
      ]
    elsif pkmn.hasType?(:DARK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is glaring up at the sky."),
        _INTL("{1} seems personally offended by the sunshine."),
        _INTL("The bright sunshine seems to bothering {1}."),
        _INTL("{1} looks upset for some reason."),
        _INTL("{1} is trying to stay in {2}'s shadow."),
        _INTL("{1} keeps looking for shelter from the sunlight.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is squinting in the bright sunshine."),
        _INTL("{1} is starting to sweat."),
        _INTL("{1} seems a little uncomfortable in this weather."),
        _INTL("{1} looks a little overheated."),
        _INTL("{1} seems very hot..."),
        _INTL("{1} shielded its vision against the sparkling light!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name, pkmnName, playerName))
    next true
  end
})
