def trainerSchoolMonitor()
    starters = [["Budew", "Roselia", "Rosereade"], ["Fletchling"], ["Grubbin"], ["Klink"], ["Pichu"], ["Roggenrola"], ["Solosis"], ["Spheal"], ["Timburr"], ["Togepi"], ["Trapinch"], ["Zigzagoon (Galarian)"], ["Cancel"]]
    information = [
        [
            "Budew, the Bud Pokémon, is a \\c[20]Grass\\c[0]/\\c[24]Poison \\c[0]type and evolves into Roselia by reaching High Friendship during Daytime. Over the winter, it closes its bud and endures the cold. In spring, the bud opens and releases pollen.",
            "Roselia",
            "Roserade"
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
    choice = pbMessage(_INTL("Which Starter would you like to display on the monitor?"),
    (0...starters.size).to_a.map{|i|
        next _INTL("{1}", starters[i][0])
        }, -1)
    return if choice == 12 || choice == -1
    pbMessage(_INTL("{1}", information[choice][0]))
    choiceTwo = pbMessage(_INTL("Do you want to continue reading about {1}'s evolution?", starters[choice][0]), [_INTL("Yes"),_INTL("No")], -1)
    return if choiceTwo == 1 || choiceTwo == -1
    pbMessage(_INTL("{1}", information[choice][1]))
    choiceThree = pbMessage(_INTL("Do you want to keep reading about {1}'s evolution?", starters[choice][1]), [_INTL("Yes"),INTL("No")], -1)
end