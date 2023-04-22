def rivalName()
    @array = $game_switches[51] ? [["\\xna", "\\xnb"], [["Ashley", "Emma", "Kaitlyn", "Other"], ["Nick","Henry","Patrick","Other"]], ["trainer_POKEMONTRAINER_May", "trainer_POKEMONTRAINER_Brendan"]] : 
                                  [["\\xnb", "\\xna"], [["Nick","Henry","Patrick","Other"], ["Ashley", "Emma", "Kaitlyn", "Other"]], ["trainer_POKEMONTRAINER_Brendan", "trainer_POKEMONTRAINER_May"]]
    confirmRival1Name = rival1Name()
    while confirmRival1Name != 0 do
        confirmRival1Name = rival1Name(confirmRival1Name)
    end
    confirmRival2Name = rival2Name()
    while confirmRival2Name != 0 do
        confirmRival2Name = rival2Name(confirmRival2Name)
    end
end

def rival1Name(confirmRival1Name = 0)
    names = (0..@array.size).to_a.map{|i|
        next _INTL("{1}", @array[1][0][i])}
    choice = confirmRival1Name == 0 ? pbMessage(_INTL("{1}[???]Nice to meet you \\PN, my name is uh...", @array[0][0]), names, -1) : pbMessage(_INTL("{1}[{2}]No? I really thought it was... Then what is it?", @array[0][0], $game_variables[45]), names, -1)
    $game_variables[45] = choice == 3 || choice == -1 ? (pbEnterNPCName(_I("Rival's name?"), 1, Settings::MAX_PLAYER_NAME_SIZE, "", @array[2][0])) : @array[1][0][choice]
    return confirmRival1Name = pbMessage(_INTL("{1}[{2}]That's right, I'm {2}!", @array[0][0], $game_variables[45]),
    [_INTL("Yes"),_INTL('No')], -1)
end


def rival2Name(confirmRival2Name = 0)
    names = (0..@array.size).to_a.map{|i|
        next _INTL("{1}", @array[1][1][i])}
    choice = confirmRival2Name == 0 ? pbMessage(_INTL("{1}[???]Nice to mee you too \\PN, I can't remember my name as well...", @array[0][1]), names, -1) : pbMessage(_INTL("{1}[{2}]No? I really can't remember then...", @array[0][1], $game_variables[46]), names, -1)
    $game_variables[46] = choice == 3 || choice == -1 ? (pbEnterNPCName(_I("Rival's name?"), 1, Settings::MAX_PLAYER_NAME_SIZE, "", @array[2][1])) : @array[1][1][choice]
    return confirmRival2Name = pbMessage(_INTL("{1}[{2}]I remember now, my name is {2}!", @array[0][1], $game_variables[46]),
    [_INTL("Yes"),_INTL('No')], -1)
end

def rivalText(input) #rival 1 = 1 and rival 2 = 2
    if input[0] != 1 && input[0] != 2
        for i in 0...input.length
            return if input[i][0] > 2 || input[i][0] < 1
            rivalName = input[i][0] == 1 ? $game_variables[45] : $game_variables[46]
            pbMessage(_INTL("{1}[{2}]{3}", @array[0][input[i][0]-1], rivalName, input[i][1].delete("\n")))
        end
    else    
        rivalName = input[0] == 1 ? $game_variables[45] : $game_variables[46]
        pbMessage(_INTL("{1}[{2}]{3}", @array[0][input[0]-1], rivalName, input[1].delete("\n")))
    end
end