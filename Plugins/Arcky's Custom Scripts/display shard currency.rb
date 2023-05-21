def displayItemCurrency(currency)
    closeCounter
    $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}</ar>", GameData::Item.get(currency).name_plural, $bag.quantity(currency)))    
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