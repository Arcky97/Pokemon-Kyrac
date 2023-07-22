module FollowingPkmn
  # Common event that contains "FollowingPkmn.talk" in  a script command
  # Change this if you want a separate common event to play when talking to
  # Following Pokemon. Otherwise, set this to nil.
  FOLLOWER_COMMON_EVENT     = nil

  # Animation IDs from followers
  #These are the PokeBall animation ID's for every type of ball
  #The Follower was caught/received in a Poke Ball.
  ANIMATION_COME_IN_POKEBALL = 29
  ANIMATION_COME_OUT_POKEBALL = 30
  #The Follower was caught/received in a Cherish Ball.
  ANIMATION_COME_IN_CHERISHBALL = 31
  ANIMATION_COME_OUT_CHERISHBALL = 32
  #The Follower was caught/received in a Dive Ball.
  ANIMATION_COME_IN_DIVEBALL = 33
  ANIMATION_COME_OUT_DIVEBALL = 34
  #The Follower was caught/received in a Dream Ball.
  ANIMATION_COME_IN_DREAMBALL = 35
  ANIAMTION_COME_OUT_DREAMBALL = 36 
  #The Follower was caught/received in a Dusk Ball.
  ANIMATION_COME_IN_DUSKBALL = 37
  ANIMATION_COME_OUT_DUSKBALL = 38
  #The Follower was caught/received in a Fast Ball.
  ANIMATION_COME_IN_FASTBALL = 39
  ANIMATION_COME_OUT_FASTBALL = 40
  #The Follower was caught/received in a Friend Ball.
  ANIMATION_COME_IN_FRIENDBALL = 41
  ANIMATION_COME_OUT_FRIENDBALL = 42
  #The Follower was caught/recieved in a Great Ball.
  ANIMATION_COME_IN_GREATBALL = 43
  ANIMATION_COME_OUT_GREATBALL = 44
  #The Follower was caught/received in a Heal Ball.
  ANIMATION_COME_IN_HEALBALL = 45
  ANIMATION_COME_OUT_HEALBALL = 46
  #The Follower was caught/received in a Heavy Ball.
  ANIMATION_COME_IN_HEAVYBALL = 47
  ANIMATION_COME_OUT_HEAVYBALL = 48
  #The Follower was caught/received in a Level Ball.
  ANIMATION_COME_IN_LEVELBALL = 49
  ANIMATION_COME_OUT_LEVELBALL = 50
  #The Follower was caught/received in a Love Ball.
  ANIMATION_COME_IN_LOVEBALL = 51
  ANIMATION_COME_OUT_LOVEBALL = 52
  #The Follower was caught/received in a Lure Ball.
  ANIMATION_COME_IN_LUREBALL = 53
  ANIMATION_COME_OUT_LUREBALL = 54
  #The Follower was caught/received in a Luxery Ball.
  ANIMATION_COME_IN_LUXURYBALL = 55
  ANIMATION_COME_OUT_LUXURYBALL = 56
  #The Follower was caught/received in a Master Ball.
  ANIMATION_COME_IN_MASTERBALL = 57
  ANIMATION_COME_OUT_MASTERBALL = 58
  #The Follower was caught/received in a Moon Ball.
  ANIMATION_COME_IN_MOONBALL = 59
  ANIMTION_COME_OUT_MOONBALL = 60
  #The Follower was caught/received in a Nest Ball.
  ANIMATION_COME_IN_NESTBALL = 61
  ANIMATION_COME_OUT_NESTBALL = 62
  #The Follower was caught/received in a Net Ball.
  ANIMATION_COME_IN_NETBALL = 63
  ANIMATION_COME_OUT_NETBALL = 64
  #The Follower was caught/received in a Premier Ball.
  ANIMATION_COME_IN_PREMIERBALL = 65
  ANIMATION_COME_OUT_PREMIERBALL = 66
  #The Follower was caught/received in a Quick Ball.
  ANIMATION_COME_IN_QUICKBALL = 67
  ANIMATION_COME_OUT_QUICKBALL = 68
  #The Follower was caught/received in a Repeat Ball.
  ANIMATION_COME_IN_REPEATBALL = 69
  ANIMATION_COME_OUT_REPEATBALL = 70
  #The Follower was caught/received in a Safari Ball.
  ANIMATION_COME_IN_SAFARIBALL = 71
  ANIMATION_COME_OUT_SAFARIBALL = 72
  #The Follower was caught/received in a Sport Ball.
  ANIMATION_COME_IN_SPORTBALL = 73
  ANIMATION_COME_OUT_SPORTBALL = 74
  #The Follower was caught/received in a Timer Ball.
  ANIMATION_COME_IN_TIMERBALL = 75
  ANIMATION_COME_OUT_TIMERBALL = 76
  #The Follower was caught/received in an ultra Ball.
  ANIMATION_COME_IN_ULTRABALL = 77
  ANIMATION_COME_OUT_ULTRABALL = 78

  #The Different Animation Marks that will appear above the Follower's head.
  ANIMATION_EMOTE_EXCLAM    = 3
  ANIMATION_EMOTE_QUESTION  = 4
  ANIMATION_EMOTE_HEART     = 9
  ANIMATION_EMOTE_HAPPY     = 10
  ANIMATION_EMOTE_SMILE     = 11
  ANIMATION_EMOTE_MUSIC     = 12
  ANIMATION_EMOTE_ELIPSES   = 13
  ANIMATION_EMOTE_SAD       = 14
  ANIMATION_EMOTE_MAD       = 15
  ANIMATION_EMOTE_ANGRY     = 16
  ANIMATION_EMOTE_POISON    = 17

  # The key the player needs to press to toggle followers. Set this to nil if
  # you want to disable this feature. (:JUMPUP is the A key by default)
  TOGGLE_FOLLOWER_KEY       = :JUMPUP

  # Show the option to toggle Following Pokemon in the Options screen.
  SHOW_TOGGLE_IN_OPTIONS    = false

  # The key the player needs to press to quickly cycle through their party. Set
  # this to nil if you want to disable this feature
  CYCLE_PARTY_KEY           = nil

  # Status tones to be used, if this is true (Red, Green, Blue)
  APPLY_STATUS_TONES        = true
  TONE_BURN                 = [206, 73, 43]
  TONE_POISON               = [109, 55, 130]
  TONE_PARALYSIS            = [204, 152, 44]
  TONE_FROZEN               = [56, 160, 193]
  TONE_SLEEP                = [0, 0, 0]
  # For your custom status conditions, just add it as "TONE_(INTERNAL NAME)"
  # Example: TONE_BLEED, TONE_CONFUSE, TONE_INFATUATION

  # Time Taken for Follower to increase Friendship when first in party (in seconds)
  FRIENDSHIP_TIME_TAKEN     = 125

  # Time Taken for Follower to find an item when first in party (in seconds)
  ITEM_TIME_TAKEN           = 375

  # Whether the Follower always stays in its move cycle (like HGSS) or not.
  ALWAYS_ANIMATE            = true

  # Whether the Follower always faces the player, or not like in HGSS.
  ALWAYS_FACE_PLAYER        = false

  # Whether other events can walk through Follower or no
  IMPASSABLE_FOLLOWER       = true

  # Whether Following Pokemon slides into battle instead of being sent
  # in a Pokeball. (This doesn't affect EBDX, read the EBDX documentation to
  # change this feature in EBDX)
  SLIDE_INTO_BATTLE         = true

  # Show the Ball Opening and Closing animation when Nurse Joy takes your
  # Pokeballs at the Pokecenter.
  SHOW_POKECENTER_ANIMATION = true

  # List of Pokemon that will always appear behind the player when surfing
  # Doesn't include any flying or water types because those are handled already
  SURFING_FOLLOWERS = [
    # Gen 1
    :BEEDRILL, :VENOMOTH, :ABRA, :GEODUDE, :MAGNEMITE, :GASTLY, :HAUNTER,
    :KOFFING, :WEEZING, :PORYGON, :MEWTWO, :MEW,
    # Gen 2
    :MISDREAVUS, :UNOWN, :PORYGON2, :CELEBI,
    # Gen 3
    :DUSTOX, :SHEDINJA, :MEDITITE, :VOLBEAT, :ILLUMISE, :FLYGON, :LUNATONE,
    :SOLROCK, :BALTOY, :CLAYDOL, :CASTFORM, :SHUPPET, :DUSKULL, :CHIMECHO,
    :GLALIE, :BELDUM, :METANG, :LATIAS, :LATIOS, :JIRACHI,
    # Gen 4
    :MISMAGIUS, :BRONZOR, :BRONZONG, :SPIRITOMB, :CARNIVINE, :MAGNEZONE,
    :PORYGONZ, :PROBOPASS, :DUSKNOIR, :FROSLASS, :ROTOM, :UXIE, :MESPRIT,
    :AZELF, :GIRATINA, :CRESSELIA, :DARKRAI,
    # Gen 5
    :MUNNA, :MUSHARNA, :YAMASK, :COFAGRIGUS, :SOLOSIS, :DUOSION, :REUNICLUS,
    :VANILLITE, :VANILLISH, :VANILLUXE, :ELGYEM, :BEHEEYEM, :LAMPENT,
    :CHANDELURE, :CRYOGONAL, :HYDREIGON, :VOLCARONA, :RESHIRAM, :ZEKROM,
    # Gen 6
    :SPRITZEE, :DRAGALGE, :CARBINK, :KLEFKI, :PHANTUMP, :DIANCIE, :HOOPA,
    # Gen 7
    :VIKAVOLT, :CUTIEFLY, :RIBOMBEE, :COMFEY, :DHELMISE, :TAPUKOKO, :TAPULELE,
    :TAPUBULU, :COSMOG, :COSMOEM, :LUNALA, :NIHILEGO, :KARTANA, :NECROZMA,
    :MAGEARNA, :POIPOLE, :NAGANADEL,
    # Gen 8
    :ORBEETLE, :FLAPPLE, :SINISTEA, :POLTEAGEIST, :FROSMOTH, :DREEPY, :DRAKLOAK,
    :DRAGAPULT, :ETERNATUS, :REGIELEKI, :REGIDRAGO, :CALYREX
  ]

  # List of Pokemon that will not appear behind the player when surfing,
  # regardless of whether they are flying type, have levitate or are mentioned
  # in the SURFING_FOLLOWERS.
  SURFING_FOLLOWERS_EXCEPTIONS = [
    # Gen I
    :CHARIZARD, :PIDGEY, :SPEAROW, :FARFETCHD, :DODUO, :DODRIO, :SCYTHER,
    :ZAPDOS_1,
    # Gen II
    :NATU, :XATU, :MURKROW, :DELIBIRD,
    # Gen III
    :TAILLOW, :VIBRAVA, :TROPIUS,
    # Gen IV
    :STARLY, :HONCHKROW, :CHINGLING, :CHATOT, :ROTOM_1, :ROTOM_2, :ROTOM_3,
    :ROTOM_5, :SHAYMIN_1, :ARCEUS_2,
    # Gen V
    :ARCHEN, :DUCKLETT, :EMOLGA, :EELEKTRIK, :EELEKTROSS, :RUFFLET, :VULLABY,
    :LANDORUS_1,
    # Gen VI
    :FLETCHLING, :HAWLUCHA,
    # Gen VII
    :ROWLET, :DARTRIX, :PIKIPEK, :ORICORIO, :SILVALLY_2,
    # Gen VIII
    :ROOKIDEE, :CALYREX_1, :CALYREX_2
  ]
end
