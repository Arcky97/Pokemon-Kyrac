def yachtQuestSeven
    if $game_variables[56] >= 5 && $bag.quantity(:OLDROD) == 1 && $game_self_switches[[122,12,"A"]] && $game_self_switches[[31,131,"B"]] && !$game_switches[59]
        $game_switches[59] = true
        pbWait(20)
        pbMessage(_INTL("\\SE[elevator ding dong]Ding Dong! Ding Dong!"))
        pbMessage(_INTL("\\xnb[Captain]Attention! This is your Captain speaking! I'm grateful to announce that the Yacht has succesfully arrived in Hester City!"))
        pbMessage(_INTL("\\xnb[Captain]The Yacht will leave only in a few hours. Feel free to come back any time in case you forgot something."))
        pbMessage(_INTL("\\xnb[Captain]To all travellers, thanks for traveling with us and have a safe trip in East-Kyrac! We hope to see you again!"))
        completeQuest(:Quest7)
        $game_variables[63] == 3
    end
end