def randomItem
    params = ChooseNumberParams.new
    params.setRange(1, 8)
    params.setInitialValue(1)
    params.setCancelValue(1)
    pocket = pbMessageChooseNumber(_INTL("Choose a Pocket number:"), params)
    items = load_data("Data/items.dat")
    pocketItem = items.keys.find_all{|i| next items[i].pocket == pocket}
    item = pocketItem[rand(0...pocketItem.length)]
    pbMessage(_INTL("The Item suggested with pocket ID {1}: {2}", pocket, item))
end

def plantItem
  hitCount = $game_variables[31]
  if hitCount % 10 == 0 || hitCount == 1
    playerProgress = $game_variables[63]
    excludeBalls = [:MASTERBALL, :SAFARIBALL, :SPORTBALL, :DIVEBALL, :PREMIERBALL, :BEASTBALL]
    loadItems = load_data("Data/items.dat")
    pokeBalls = loadItems.keys.select { |i| loadItems[i].pocket == 3 && !excludeBalls.include?(i) }
    ballRarity = {
      :ULTRABALL => 7, 
      :GREATBALL => 4, 
      :POKEBALL => 1, 
      :NETBALL => 3,
      :NESTBALL => 2, 
      :REPEATBALL => 6, 
      :TIMERBALL => 7, 
      :LUXURYBALL => 3, 
      :DUSKBALL => 4, 
      :HEALBALL => 3, 
      :QUICKBALL => 6, 
      :CHERISHBALL => 2, 
      :FASTBALL => 3, 
      :LEVELBALL => 4, 
      :LUREBALL => 2, 
      :HEAVYBALL => 6, 
      :LOVEBALL => 2, 
      :FRIENDBALL => 3, 
      :MOONBALL => 2, 
      :DREAMBALL => 4, 
      :INSECTBALL => 2, 
      :DREADBALL => 3, 
      :DRACOBALL => 6, 
      :ZAPBALL => 5, 
      :PIXIEBALL => 6, 
      :FISTBALL => 4, 
      :FLAMEBALL => 4, 
      :SKYBALL => 3, 
      :SPOOKYBALL => 4, 
      :MEADOWBALL => 5, 
      :EARTHBALL => 2, 
      :ICICLEBALL => 3, 
      :BLANKBALL => 2, 
      :TOXICBALL => 4, 
      :MINDBALL => 4, 
      :STONEBALL => 4, 
      :IRONBALL => 4, 
      :SPLASHBALL => 4
    }
    availableBalls = pokeBalls.select { |ball| ballRarity[ball] <= playerProgress }
    pbMessage(_INTL("Something fell out of the plant."))
    pbItemBall(availableBalls[rand(0...availableBalls.length)], 1)
    $game_variables[34] += 1
  end
end