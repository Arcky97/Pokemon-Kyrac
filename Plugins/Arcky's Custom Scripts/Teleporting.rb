def teleporting()
    @choice = pbMessage(_INTL("Where do you want to teleport to?"), 
    (0...$telSwitches.size).to_a.map{|i| 
      next _INTL("{1}", $telSwitches[i])
    }, -1)
    return if 0 > @choice 
end

def addSwitchTeleport(switchID, switchName, mapID, mapX, mapY)
    $telSwitches = [] if $telSwitches == nil
    $telSwitches.push(switchName) if $game_switches[switchID] && !$telSwitches.include?(switchName)
end