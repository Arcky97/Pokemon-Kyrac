def displayCounterWindow(object, value, total=0, bonusTotal=0)
  closeCounter
  itemsFound = value != 0 && object != "Money" ? $game_variables[value] : $player.money.to_s_formatted
  total = bonusTotal != 0 && bonusTotal != nil ? total.to_s + "(+" + bonusTotal.to_s + ")" : total
  counter = total != 0 ? itemsFound.to_s + "/" + total.to_s : itemsFound
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

def objectCounter(object, value, total=0, mapArrayToUse=nil)
  total = 0 if $player.badge_count > 0
  arrayMaps = arrayDecider(mapArrayToUse)
  objectCounter = []
  if total == 0 && value != 0
    if mapArrayToUse
      for i in 1...arrayMaps.length
        mapIDName = sprintf("Data/Map%03d.rxdata", arrayMaps[i])
        map = load_data(mapIDName)
        objectCounter.push(countObjects(object, map))
      end
    else
      mapID = $game_map.map_id 
      map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
      objectCounter = countObjects(object, map) #returns [objectCounter, bonusCounter]
    end
    objectCounter = objectCounter.transpose.map(&:sum) if objectCounter.length > 2
    objectCounter[0] -= objectCounter[1] # objectCounter - bonusCounter
  end
  total = objectCounter[0] if objectCounter[0] != nil
  bonusTotal = objectCounter[1] if objectCounter[1] != nil
  displayCounterWindow(object, value, total, bonusTotal)
end

def countObjects(object, map)
  bonusArray = fieldMoveItems
  objectCounter, bonusCounter = 0, 0
  for i in map.events.keys
    next if !map.events[i].name.include?(object.chop) 
    objectCounter += 1
    for j in 0...bonusArray.length
      next if !map.events[i].name.include?(bonusArray[j])
      bonusCounter += 1
    end
  end
  return objectCounter, bonusCounter
end

def fieldMoveItems
  fieldMoves = {
    1 => "RS",
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
  arrayMaps = $arrayMaps if $arrayMaps !=0
  case mapArrayToUse
  when "Yacht"
    arrayMaps = [0, 32, 22, 14, 18, 12, 38, 122, 36, 37, 25, 26, 27]
    arrayMaps.push(30) if $player.badge_count >= 1
  end
  $arrayMaps = arrayMaps
  return arrayMaps
end