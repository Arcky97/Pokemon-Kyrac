def yachtQuestSeven ()
    if $game_variables[30] >= 5 && $bag.quantity(:OLDROD) == 1 && $game_switches[113] && $game_switches[115] && !$game_switches[86]
        $game_switches[85] = false
        $game_switches[86] = true
        pbMessage(_INTL("Ding Dong! Ding Dong!"))
        pbMessage(_INTL("\\xnb[Captain]Attention! This is your Captain speaking! I'm grateful to announce that the Yacht has succesfully arrived in Hester City!"))
        pbMessage(_INTL("\\xnb[Captain]The Yacht will leave only in a few hours. Feel free to come back any time incase you forgot something."))
        pbMessage(_INTL("\\xnb[Captain]To all travelers, thanks for traveling with us and have a safe trip in East-Kyrac! We hope to see you again!"))
    end
end

