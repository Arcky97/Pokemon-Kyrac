def displayCounterWindow(object, gameVar, itemTotal=0, bonusTotal=0)
  closeCounter
  itemsFound = $game_variables[gameVar]
  total = bonusTotal != 0 ? itemTotal.to_s + "(+" + bonusTotal.to_s + ")" : itemTotal
  counter = itemTotal != 0 ? itemsFound.to_s + "/" + total.to_s : itemsFound
  $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}</ar>", object, counter))    
  $counterwindow.setSkin("Graphics/Windowskins")
  $counterwindow.resizeToFit($counterwindow.text, Graphics.width)
  $counterwindow.width = 160 if $counterwindow.width >= 130
  return $counterwindow
end

def closeCounter 
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
  itemCounter = []
  if mapArrayToUse
    for i in 1...arrayMaps.length
      mapIDName = sprintf("Data/Map%03d.rxdata", arrayMaps[i])
      map = load_data(mapIDName)
      itemCounter.push(countItems(map, mapArrayToUse))
    end
  else
    mapID = $game_map.map_id 
    map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
    itemCounter = countItems(map, mapArrayToUse) #returns [itemCounter, bonusCounter]
  end
  itemCounter = itemCounter.transpose.map(&:sum) if itemCounter.length > 2
  itemCounter[0] -= itemCounter[1] # itemCounter - bonusCounter
  displayCounterWindow("Items", gameVar, itemCounter[0], itemCounter[1])
end

def countItems(map, mapArrayToUse)
  bonusArray = fieldMoveItems
  itemCounter, bonusCounter = 0, 0
  for i in map.events.keys
    next if !map.events[i].name.include?("Item") 
    itemCounter += 1
    for j in 0...bonusArray.length
      next if !map.events[i].name.include?(bonusArray[j]) 
      bonusCounter += 1
    end
  end
  return itemCounter, bonusCounter
end

def fieldMoveItems
  fieldMoves = {
    1 => "RC",
    3 => "CU",
    4 => "SU",
    5 => "ST",
    6 => "FL",
    8 => "WF"
  }
  ret = []
  for maxBadgeCount in fieldMoves.keys
    ret.push(fieldMoves[maxBadgeCount]) if $player.badge_count < maxBadgeCount
  end
  return ret
end

def arrayDecider(mapArrayToUse)
  arrayYacht = $game_variables[63] if $game_variables[63] !=0
  case mapArrayToUse
  when "YachtBegin"
    arrayYacht = [0, 32, 22, 30, 14, 18, 12, 38, 122, 36, 37, 25, 26, 27]
  when "YachtGym"
    arrayYacht.push(28) if !arrayYacht.include?(28)
  when "YachtFinal"
    arrayYacht.push()
  when "YachtPost"
    arrayYacht.push()
  end
  $game_variables[63] = arrayYacht
  return arrayYacht
end