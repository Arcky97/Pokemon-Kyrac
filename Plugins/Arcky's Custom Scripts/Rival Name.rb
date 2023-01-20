def rivalName()
    array = $game_switches[96] ? [["\\xna", "\\xnb"], [["Ashley", "Emma", "Kaitlyn", "Other"], ["Nick","Henry","Patrick","Other"]], ["trainer_POKEMONTRAINER_May", "trainer_POKEMONTRAINER_Brendan"]] : 
                                  [["\\xnb", "\\xna"], [["Nick","Henry","Patrick","Other"], ["Ashley", "Emma", "Kaitlyn", "Other"]], ["trainer_POKEMONTRAINER_Brendan", "trainer_POKEMONTRAINER_May"]]
    confirmRival1Name = rival1Name(array)
    while confirmRival1Name != 0 do
        confirmRival1Name = rival1Name(array, confirmRival1Name)
    end
    confirmRival2Name = rival2Name(array)
    while confirmRival2Name != 0 do
        confirmRival2Name = rival2Name(array, confirmRival2Name)
    end
end

def rival1Name(array, confirmRival1Name = 0)
    names = (0..array.size).to_a.map{|i|
        next _INTL("{1}", array[1][0][i])}
    choice = confirmRival1Name == 0 ? pbMessage(_INTL("{1}[???]Nice to meet you \\PN, my name is uh...", array[0][0]), names, -1) : pbMessage(_INTL("{1}[{2}]No? I really thought it was... Then what is it?", array[0][0], $game_variables[52]), names, -1)
    $game_variables[52] = choice == 3 || choice == -1 ? (pbEnterNPCName(_I("Rival's name?"), 1, Settings::MAX_PLAYER_NAME_SIZE, "", array[2][0])) : array[1][0][choice]
    return confirmRival1Name = pbMessage(_INTL("{1}[{2}]That's right, I'm {2}!", array[0][0], $game_variables[52]),
    [_INTL("Yes"),_INTL('No')], -1)
end


def rival2Name(array, confirmRival2Name = 0)
    names = (0..array.size).to_a.map{|i|
        next _INTL("{1}", array[1][1][i])}
    choice = confirmRival2Name == 0 ? pbMessage(_INTL("{1}[???]Nice to mee you too \\PN, I can't remember my name as well...", array[0][1]), names, -1) : pbMessage(_INTL("{1}[{2}]No? I really can't remember then...", array[0][1], $game_variables[53]), names, -1)
    $game_variables[53] = choice == 3 || choice == -1 ? (pbEnterNPCName(_I("Rival's name?"), 1, Settings::MAX_PLAYER_NAME_SIZE, "", array[2][1])) : array[1][1][choice]
    return confirmRival2Name = pbMessage(_INTL("{1}[{2}]I remember now, my name is {2}!", array[0][1], $game_variables[53]),
    [_INTL("Yes"),_INTL('No')], -1)
end