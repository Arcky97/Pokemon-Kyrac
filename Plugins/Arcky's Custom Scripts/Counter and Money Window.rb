def DisplayCounterWindow(object,var,total)
    close_counter
    var = $game_variables[var]
    $counterwindow = Window_AdvancedTextPokemon.new(_INTL("{1}:<ar>{2}/{3}</ar>", object, var, total))
    $counterwindow.setSkin("Graphics/Windowskins")
    $counterwindow.resizeToFit($counterwindow.text, Graphics.width)
    $counterwindow.width = 130 if $counterwindow.width >= 130
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