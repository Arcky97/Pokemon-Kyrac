def rivalName()
    arrays = $game_switches[96] ? [["\\xna", "\\xnb"], [["Ashley", "Emma", "Kaitlyn", "Other"], ["Nick","Henry","Patrick","Other"]], "trainer_POKEMONTRAINER_May"] : 
                                  [["\\xnb", "\\xna"], [["Nick","Henry","Patrick","Other"], ["Ashley", "Emma", "Kaitlyn", "Other"]], "trainer_POKEMONTRAINER_Brendan"]
    choice = pbMessage(_INTL("{1}[???]Nice to meet you \\PN, my name is uh...", arrays[0][0]),
    (0...arrays[1][0].size).to_a.map{|i|
        next _INTL("{1}", arrays[1][0][i])
    })
    arrays[1][0].push(pbEnterNPCName(_I("Rival's name?"), 1, Settings::MAX_PLAYER_NAME_SIZE, "", arrays[2])) if choice == 3
    $game_variables[52] = arrays[1][0].length == 4 ? arrays[1][0][choice] : arrays[1][0][4]
    pbMessage(_INTL("{1}[{2}]That's right, I'm {2}!", arrays[0][0], $game_variables[52]))

end