def displayCounterWindow(object, value, total=0, bonusTotal=0)
  closeCounter
  itemsFound = value != 0 && object != "Money" ? $game_variables[value] : $player.money.to_s_formatted
  total = bonusTotal != 0 && bonusTotal != nil ? total.to_s + "(+" + bonusTotal.to_s + ")" : total
  counter = total != 0 ? itemsFound.to_s + "/" + total.to_s : itemsFound
  $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}: {2}", object, counter))    
  $counterwindow.resizeToFit($counterwindow.text, Graphics.width)
  return $counterwindow
end

def closeCounter 
  return if !$counterwindow
  $counterwindow.dispose
  $counterwindow = nil
end

def objectCounter(object, value, total=0, arrayToUse=nil)
  total = 0 if $player.badge_count > 0
  array = arrayDecider(arrayToUse)
  objectCounter = []
  if total == 0 && value != 0
    if array[0].length > 1
      for i in 0...array[0].length
        mapIDName = sprintf("Data/Map%03d.rxdata", array[0][i])
        map = load_data(mapIDName)
        objectCounter.push(countObjects(object, map, array[1]))
      end
      objectCounter = objectCounter.transpose.map(&:sum) if objectCounter.length >= 2
      objectCounter[0] -= objectCounter[1] if objectCounter[1] # objectCounter - bonusCounter
    else
      mapID = arrayToUse ? array[0][0] : $game_map.map_id 
      map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
      objectCounter = countObjects(object, map, array[1]) #returns [objectCounter, bonusCounter]
    end
  end
  total = objectCounter[0] if objectCounter[0] != nil
  bonusTotal = objectCounter[1] if objectCounter[1] != nil
  displayCounterWindow(object, value, total, bonusTotal)
end

def countObjects(object, map, switches)
  bonusArray = fieldMoveItems + badgeItems
  objectCounter, bonusCounter = 0, 0
  eventsToExcl = []
  switches.each do |switch|
    convertedSwitch = convertSwitchName(switch)
    eventsToExcl.push(convertedSwitch)
  end
  lastOnSwitch = nil
  if switches 
    switches.reverse_each do |switch|
      if $game_switches[switch]
        lastOnSwitch = switch
        break
      end 
    end 
    switchName = convertSwitchName(lastOnSwitch) if lastOnSwitch
  end 
  eventsToExcl.delete_if { |element| element == switchName }
  for i in map.events.keys
    next if !map.events[i].name.to_s.include?(object.to_s.chop) || eventsToExcl.any? { |excl| map.events[i].name.to_s.include?(excl.to_s) }
    objectCounter += 1
    for j in 0...bonusArray.length
      next if !map.events[i].name.include?(bonusArray[j])
      bonusCounter += 1
    end
  end
  return objectCounter, bonusCounter
end

def convertSwitchName(switch)
  name = $data_system.switches[switch]
  words = name.split(" ")
  result = ""
  words.each do |word|
    result += word[0].upcase if word.length > 0
  end 
  return result
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

def badgeItems
  badgeCount = {
    1 => "1 Badge",
    2 => "2 Badges",
    3 => "3 Badges",
    4 => "4 Badges"
  }
  ret = []
  for maxBadgeCount in badgeCount.keys 
    ret.push(badgeCount[maxBadgeCount]) if $player.badge_count < maxBadgeCount
  end 
  return ret 
end

def arrayDecider(arrayToUse)
  array = [[], []]
  case arrayToUse
  when "Yacht"
    array = [[24, 31, 122], [59, 66]] #map IDs to count objects from and game switch ID to take in account.
  end
  return array
end