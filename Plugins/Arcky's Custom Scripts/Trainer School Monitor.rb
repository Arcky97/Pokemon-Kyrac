def trainerSchoolMonitor(input)
    starters = [[:BUDEW, :ROSELIA, :ROSERADE], [:FLETCHLING, :FLETCHINDER, :TALONFLAME], [:GRUBBIN, :CHARJABUG, :VIKAVOLT], [:KLINK, :KLANG, :KLINKLANG], [:PICHU, :PIKACHU, [:RAICHU, :RAICHU_1]], [:ROGGENROLA, :BOLDORE, :GIGALITH], 
    [:SOLOSIS, :DUOSION, :REUNICLUS], [:SPHEAL, :SEALEO, :WALREIN], [:TIMBURR, :GURDURR, :CONKELDURR], [:TOGEPI, :TOGETIC, :TOGEKISS], [:TRAPINCH, :VIBRAVA, :FLYGON], [:ZIGZAGOON_1, :LINOONE, :OBSTAGOON]]
    evolutionMethod = [["by reaching High Friendship during Daytime", "by using a Shiny Stone"], ["at level 17"], ["at level 20"], ["at level 38"], ["by reaching High Friendship"], ["at level 25"], ["at level 32"], ["at level 32"], ["at level 25"], ["by reaching High Friendship"], ["at level 35"], ["at level 20"]]
    typeColor = [[20, 24], [23, 18], [11], [27], [14], [26], [25], [22, 28], [16], [15], [21], [12, 23]]
    species = GameData::Species.get(starters[input][0])
    show_image_pokemon_retain_open(starters[input][0])
    pokemon = input == 11 ? "Galarian #{species.name}" : species.name
    type = typeColor[input][1] ? "\\c[#{typeColor[input][0]}]#{species.types[0].name.capitalize}\\c[0]/\\c[#{typeColor[input][1]}]#{species.types[1].name.capitalize}" : "\\c[#{typeColor[input][0]}]#{species.types[0].name.capitalize}"
    pbMessage(_INTL("{1}, the {2} Pokémon, is a {3}-Type \\c[0]and evolves into {4} {5}. {6}", pokemon, species.real_category, type, starters[input][1].name.capitalize, evolutionMethod[input][0], species.real_pokedex_entry))
    close_image_pokemon
end

def trainerSchoolTypeMatchUps
    types = [:BUG, :DARK, :DRAGON, :ELECTRIC, :FAIRY, :FIGHTING, :FIRE, :FLYING, :GHOST, :GRASS, :GROUND, :ICE, :NORMAL, :POISON, :PSYCHIC, :ROCK, :STEEL, :WATER]
    choice = pbMessage(_INTL("Which Type would you like to read about?"),
                       (0...types.size).to_a.map { |i|
                         _INTL("#{GameData::Type.get(types[i]).name}")
                       }, -1)
    return if 0 > choice 
    superEffective = []
    notEffective = []
    noEffect = []
    GameData::Type.each do |type|
      if type.weaknesses.include?(types[choice])
        superEffective << [type.name, (types.index(type.id)) + 11]
      elsif type.resistances.include?(types[choice])
        notEffective << [type.name, (types.index(type.id)) + 11]
      elsif type.immunities.include?(types[choice])
        noEffect << [type.name, (types.index(type.id)) + 11]
      end
    end
    noEffect = noEffect != [] ? "And have no effect against #{formatTypeList(noEffect)}" : "No types are immune to \\c[#{choice + 11}]#{GameData::Type.get(types[choice]).name}"
    pbMessage(_INTL("\\c[#{choice + 11}]#{GameData::Type.get(types[choice]).name}-Type \\c[0]moves are super-effective against #{formatTypeList(superEffective)}. Not very effective against #{formatTypeList(notEffective)}. #{noEffect}."))
  end

  def formatTypeList(types)
    case types.size
    when 0
      "no Pokémon"
    when 1
        "\\c[#{types[0][1]}]#{types[0][0]}-Type \\c[0]Pokémon"
    when 2
      "\\c[#{types[0][1]}]#{types[0][0]}-Type \\c[0]and \\c[#{types[1][1]}]#{types[1][0]}-Type \\c[0]Pokémon"
    else
        lastType = types.pop
        formattedList = types.map { |type| 
            "\\c[#{type[1]}]#{type[0]}-Type\\c[0]" }.join(', ')
        "#{formattedList} and \\c[#{lastType[1]}]#{lastType[0]}-Type \\c[0]Pokémon"
    end
  end


=begin
    choice = pbMessage(_INTL("Do you want to continue reading about {1}'s evolution?", species.name), [_INTL("Yes"),_INTL("No")], -1)
    return if choice != 0
    close_image_pokemon
    species = GameData::Species.get(starters[input][1])
    show_image_pokemon_retain_open(starters[input][1])
    pbMessage(_INTL("{1}, the {2} Pokémon, is a \\c[20]{3}\\c[0]/\\c[24]{4} \\c[0]type and evolves into {5} {6}. {7}", species.name, species.real_category, 
        species.types[0].name.capitalize, species.types[1].name.capitalize, starters[input][2].name.capitalize, evolutionMethod[input][1], species.real_pokedex_entry))
    choice = pbMessage(_INTL("Do you want to continue reading about {1}'s evolution?", species.name), [_INTL("Yes"),_INTL("No")], -1)
    return if choice != 0
    close_image_pokemon
    species = GameData::Species.get(starters[input][2])
    show_image_pokemon_retain_open(starters[input][2])
    pbMessage(_INTL("{1}, the {2} Pokémon, is a \\c[20]{3}\\c[0]/\\c[24]{4} \\c[0]type. {7}", species.name, species.real_category, 
        species.types[0].name.capitalize, species.types[1].name.capitalize, starters[input][2].name.capitalize, evolutionMethod[input][1], species.real_pokedex_entry))
    close_image_pokemon
=end

=begin
 #starters = [["Budew", "Roselia", "Roserade"], ["Fletchling"], ["Grubbin"], ["Klink"], ["Pichu"], ["Roggenrola"], ["Solosis"], ["Spheal"], ["Timburr"], ["Togepi"], ["Trapinch"], ["Zigzagoon (Galarian)"], ["Cancel"]]
    choice = pbMessage(_INTL("Which Starter would you like to display on the monitor?"),
    (0...starters.size).to_a.map{|i|
        next _INTL("{1}", starters[i][0])
        }, -1)
    return if choice == 12 || choice == -1
    information = [
        [
            "Budew, the Bud Pokémon, is a \\c[20]Grass\\c[0]/\\c[24]Poison \\c[0]type and evolves into Roselia by reaching High Friendship during Daytime. Over the winter, it closes its bud and endures the cold. In spring, the bud opens and releases pollen.",
            "Roselia, the Torn Pokémon, is a \\c[20]Grass\\c[0]/\\c[24]Poison \\c[0]Type and evolves into Roserade by using a Shiny Stone. A roselia that drinks nutritionally rich springwater blooms with lovely flowers. The fragrance of its flowers has the effect of making its foe careless.",
            "Roserade, the Bouquet Pokémon, is a \\c[20]Grass\\c[0]/\\c[24]Poison \\c[0]Type. It attracts prey with a sweet aroma, then downs it with thorny whips hidden in its arms."
        ],    
        "Fletchling, the Tiny Robin Pokémon, is a \\c[23]Normal\\c[0]/\\c[18]Flying \\c[0]type and evolves into Fletchinder at level 17. These friendly Pokémon send signals to one another with beautiful chirps and tail-feather movements.",
        "Grubbin, the Larva Pokémon, is a \\c[11]Bug \\c[0]type and evolves into Charjabug at level 20. It spits a sticky thread to stop opponents in their tracks, and then it grabs them in its sharp, sturdy mandibles to take them down.",
        "Klink, the Gear Pokémon, is a \\c[27]Steel \\c[0]type and evolves into Klang at level 38. Interlocking two bodies and spinning around generates the energy they need to live.",
        "Pichu, the Tiny Mouse Pokémon, is a \\c[14]Electric \\c[0]type and evolves into Pikachu by reaching High Friendship. It is still inept at retaining electricity. When it is startled, it discharges power accidentally. It gets better at holding power as it grows older.",
        "Roggenrola, the Mantle Pokémon, is a \\c[26]Rock \\c[0]type and evolves into Boldore at level 25. They were discovered a hundred years ago in an earthquake fissure. Inside each one is an energy core.",
        "Solosis, the Cell Pokémon, is a \\c[25]Psychic \\c[0]type and evolves into Duosion at level 32. Because their bodies are enveloped in a special liquid, they can survive any environment.",
        "Spheal, the Clap Pokémon, is a \\c[22]Ice\\c[0]/\\c[28]Water \\c[0]type and evolves into Sealeo at level 32. It is completely covered with plushy fur. As a result, it never feels cold even when it is rolling about on ice floes or diving in the sea.",
        "Timburr, the Muscular Pokémon, is a \\c[16]Fighting \\c[0]type and evolves into Gurdurr at level 25. These Pokémon appear at building sites and help out with construction. They always carry squared logs.",
        "Togepi, the Spike Ball Pokémon, is a \\c[15]Fairy \\c[0]type and evolves into Togetic by reaching High Friendship. As its energy, it uses the feelings of compassion and pleasure exuded by people and Pokémon. It stores up happy feelings in its shell, then shares them out.",
        "Trapinch, the Ant Pit Pokémon, is a \\c[21]Ground \\c[0]type and evolves into Vibrava at level 35. Its big jaws crunch through boulders. Because its head is so big, it has a hard time getting back upright if it tips over onto its back.",
        "(Galarian) Zigzagoon, the Tiny Raccoon Pokémon, is a \\c[23]Normal\\c[0]/\\c[12]Dark \\c[0]Type and evolves into (Galarian) Linoone at level 20. It's restlessness has it constantly running around. If it sees another Pokémon, it will purposely run into them in order to start a fight.",
        ]   
    echoln(GameData::Species.get(displayImage[input][0]).name) #species name
    echoln(GameData::Species.get(displayImage[input][0]).real_pokedex_entry) #pokedex entry
    echoln(GameData::Species.get(displayImage[input][0]).real_category) #pokemon category
    echoln(GameData::Species.get(displayImage[input][0]).types[1].name.capitalize) #Pokemon type
=end



def revertColors
  textcolors = [
    ["57A8F5", "485058",   "# 1  Blue"],
    ["F8A8B8", "485058",   "# 2  Red"],
    ["B0D090", "485058",   "# 3  Green"],
    ["A8E0E0", "485058",   "# 4  Cyan"],
    ["E8A0E0", "485058",   "# 5  Magenta"],
    ["F8E888", "485058",   "# 6  Yellow"],
    ["D0D0D8", "485058",   "# 7  Grey"],
    ["C8C8D0", "485058",   "# 8  White"],
    ["B8A8E0", "485058",   "# 9  Purple"],
    ["F8C898", "485058",   "# 10 Orange"],
    ["C8E097", "485058",   "# 11 Bug Type"],
    ["96A0A7", "485058",   "# 12 Dark Type"],
    ["B79BFC", "485058",   "# 13 Dragon Type"],
    ["FAE99E", "485058",   "# 14 Electric Type"],
    ["FED6E4", "485058",   "# 15 Fairy Type"],
    ["DF9793", "485058",   "# 16 Fighting Type"],
    ["F7BF97", "485058",   "# 17 Fire Type"],
    ["C7D4EF", "485058",   "# 18 Flying Type"],
    ["A9B4D6", "485058",   "# 19 Ghost Type"],
    ["B1DEAD", "485058",   "# 20 Grass Type"],
    ["EFDFB4", "485058",   "# 21 Ground Type"],
    ["B9E7E0", "485058",   "# 22 Ice Type"],
    ["C9CED1", "485058",   "# 23 Normal Type"],
    ["D5B5E4", "485058",   "# 24 Poison Type"],
    ["FBABC3", "485058",   "# 25 Psychic Type"],
    ["E2DBC6", "485058",   "# 26 Rock Type"],
    ["ADC7D1", "485058",   "# 27 Steel Type"],
    ["A8C8EB", "485058",   "# 28 Water Type"]
  ]
  for i in 0...textcolors.length 
    echoln("\"#{textcolors[i][0]}\", \"#{textcolors[i][1]}\",   #{textcolors[i][2]}")
  end 
end
    