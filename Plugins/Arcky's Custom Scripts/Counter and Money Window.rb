def DisplayCounterWindow(object,gameVar,total)
    close_counter
    gameVar = $game_variables[gameVar]
    total != 0 ? gameVar.to_s + "/" + total.to_s : nil
    $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}</ar>", object, total))    
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

  def itemCounter(gameVar, mapNameToUse=nil, object="Items")
    gameVar = $game_variables[gameVar]
    mapList = []
    if gameVar == 0
      $itemCounter = 0
      if mapNameToUse
        mapinfos = load_data("Data/MapInfos.rxdata")
        for i in 1..mapinfos.length
          mapIDName = sprintf("Data/Map%03d.rxdata", i)
          next if !File.exist?(mapIDName)
          map = load_data(mapIDName)
          next if mapinfos[i].name!= mapNameToUse
          mapList.push(sprintf("%03d", i))
          $itemCounter += eventCounter(map)
        end
      else
        mapID = $game_map.map_id 
        map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
        $itemCounter = eventCounter(map) 
      end
    end
    DisplayCounterWindow("Items",gameVar,$itemCounter)
  end

  def eventCounter(map)
    itemCounter = 0
    for i in map.events.keys
      next if map.events[i].name!= "Item" 
      itemCounter += 1
    end
    return itemCounter
  end