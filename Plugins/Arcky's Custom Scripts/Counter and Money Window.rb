def DisplayCounterWindow(object,var,total)
    close_counter
    var = $game_variables[var]
    if total != nil
      $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}/{3}</ar>", object, var, total))
    else
      $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}</ar>", object, var))
    end
    $counterwindow.setSkin("Graphics/Windowskins")
    $counterwindow.resizeToFit($counterwindow.text, Graphics.width)
    $counterwindow.width = 160 if $counterwindow.width >= 130
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

  def itemCounter(var, useMapAllName, mapName)
    number = $game_variables[var]
    mapList = []
    if number == 0
      $itemCounter = 0
      if useMapAllName
        mapinfos = load_data("Data/MapInfos.rxdata")
        for i in 1..999
          mapIDName = sprintf("Data/Map%03d.rxdata", i)
          next if !File.exist?(mapIDName)
          map = load_data(mapIDName)
          next if !mapinfos[i].name.include? mapName
          mapList.push(sprintf("%03d", i))
          $itemCounter += evenCounter(map)
        end
      else
        mapID = $game_map.map_id 
        map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
        $itemCounter = evenCounter(map) 
      end
    end
    DisplayCounterWindow("Items",var,$itemCounter)
  end

  def evenCounter(map)
    itemCounter = 0
    for i in map.events.keys
      next if !map.events[i].name.include? "Item" 
      itemCounter += 1
    end
    return itemCounter
  end