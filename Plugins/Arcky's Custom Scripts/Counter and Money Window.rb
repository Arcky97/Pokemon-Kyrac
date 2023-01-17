def DisplayCounterWindow(object,gameVar,itemTotal=0, bonusTotal=0)
  close_counter
  total = bonusTotal != 0 ? itemTotal.to_s + "(+" + bonusTotal.to_s + ")" : itemTotal
  counter = itemTotal != 0 ? $game_variables[gameVar].to_s + "/" + total.to_s : $game_variables[gameVar]
  $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}</ar>", object, counter))    
  $counterwindow.setSkin("Graphics/Windowskins")
  $counterwindow.resizeToFit($counterwindow.text, Graphics.width)
  $counterwindow.width = 160 if $counterwindow.width >= 130
  #$game_variables[gameVar] = [item, bonus]
  return $counterwindow
end
  
def close_counter 
  return if !$counterwindow
  $counterwindow.dispose
  $counterwindow = nil
end

def pbDisplayMoneyWindow
  close_money
  $moneywindow = Window_AdvancedTextPokemon.new(_INTL("Money:\n<ar>${1}</ar>", $player.money.to_s_formatted))
  $moneywindow.setSkin("Graphics/Windowskins")
  $moneywindow.resizeToFit($moneywindow.text, Graphics.width)
  $moneywindow.width = 160 if $moneywindow.width <= 160
  return $moneywindow
end

def close_money 

  return if !$moneywindow
  $moneywindow.dispose
  $moneywindow = nil
end

def itemCounter(gameVar, mapArrayToUse=nil, object="Items")
  arrayMaps = arrayDecider(mapArrayToUse)
  gameVar = $game_variables[gameVar]
  if gameVar == 0
    $itemCounter = 0
    if mapArrayToUse
      for i in 1...arrayMaps.length
        mapIDName = sprintf("Data/Map%03d.rxdata", arrayMaps[i])
        map = load_data(mapIDName)
        $itemCounter += countItems(map)
      end
    else
      mapID = $game_map.map_id 
      map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
      $itemCounter = countItems(map) #returns [itemCounter, bonusCounter]
      echoln($itemCounter)
    end
  end
  $itemCounter[0] -= $itemCounter[1] # itemCounter - bonusCounter
  DisplayCounterWindow("Items",gameVar,$itemCounter[0], $itemCounter[1])
end

def countItems(map)
  $bonusArray = ["- RC", "- CU", "- SU", "- ST", "- FL", "- WF"]
  badges = $player.badge_count
  $bonusArray.delete_at(1) if badges == 1
  itemCounter, bonusCounter = 0, 0
  for i in map.events.keys
    next if !map.events[i].name.include?("Item") 
    itemCounter += 1
    for j in 0...$bonusArray.length
      next if !map.events[i].name.include?($bonusArray[j]) 
      bonusCounter += 1
    end
  end
  itemCounter 
  return itemCounter, bonusCounter
end

def arrayDecider(mapArrayToUse)
  arrayYacht = $game_variables[63] if $game_variables[63] !=0
  case mapArrayToUse
  when "YachtBegin"
    arrayYacht = [32, 22, 30, 14, 18, 12, 38, 122, 36, 37, 25, 26, 27]
    echoln("I'll only do this 1 time")
  when "YachtGym"
    arrayYacht.push(28) if !arrayYacht.include?(28)
    echoln("Just like the one above me, I'll only do this 1 time")
  when "YachtFinal"
    arrayYacht.push()
  when "YachtPost"
    arrayYacht.push()
  end
  $game_variables[63] = arrayYacht
  return arrayYacht
end