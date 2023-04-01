def randomItem() #pocket and badge are the only thing the script needs which is the number of the pocket to choose an item from.
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