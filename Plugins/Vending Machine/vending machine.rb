$Snacks = [:PEWTERCRUNCHIES, :RAGECANDYBAR,:LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,:BIGMALASADA]
$Drinks = [:FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK, :BERRYJUICE]
$ItemList = []

def pbVendingMachine(input,discount)
    $input = input
    $discount = discount
    pbMessage(_INTL("Look! It's a Vending Machine"))
    if $input == "snack"
        $ItemList = $Snacks
    elsif $input == "drink"
        $ItemList = $Drinks
    end
    pbMenu
end

def pbMenu
    choice = pbMessage(_INTL("Which {1} would you like to buy?\\G", $input), 
    (0...$Snacks.size).to_a.map{|i| 
      next _INTL("{1} - ${2}", GameData::Item.get($ItemList[i]).name, (GameData::Item.get($ItemList[i]).price) - $discount)
    }, -1, choice)
    case choice
    when 0..7
        if $player.money >= (GameData::Item.get($ItemList[choice]).price) - $discount
            if $bag.can_add?($ItemList[choice])
               $player.money -= (GameData::Item.get($ItemList[choice]).price) - $discount
               $game_variables[39] += 1
               $Item = GameData::Item.get($ItemList[choice]).name
               number = 0
                if random(number) == 5
                    kick = pbMessage(_INTL("\\GOh no! Your {1} got stuck! Do you want to try to kick the machine?", $Item),
                    [_INTL("Yes"),_INTL('No')], -1)
                    case kick
                    when 0
                        if random(number) != 5
                            $bag.add($ItemList[choice])
                            pbMessage(_INTL("\\GYour kick worked and the \\c[1]{1} \\c[0]dropped down!", $Item))
                            if random(number) ==5
                                bonus(choice)
                            end
                            pbMenu
                        else
                            pbMessage(_INTL("\\GYour kick didn't work and the you lost your \\c[1]{1} \\c[0]!", $Item))
                        end
                    else
                        pbMessage(_INTL("\\GLooks like you don't mind wasting your money!"))
                    end
                else
                    $bag.add($ItemList[choice])
                    pbMessage(_INTL("\\se[Vending machine sound]\\GA \\c[1]{1} \\c[0]dropped down!", $Item))
                    if random(number) == 5
                        bonus(choice)
                    end
                    pbMenu
                end
            else
                pbMessage(_INTL("\\GYou have no room left in your Bag."))
            end
        else
            pbMessage(_INTL("\\GYou don't have enought money!"))
        end
    end
end

def random(number)
    return $number = $number.rand(0..10)
end

def bonus(choice)
    if $bag.can_add?($ItemList[choice])
        $bag.add($ItemList[choice])
        pbMessage(_INTL("\\se[Vending machine sound]\\GBonus! Another \\c[1]{1} \\c[0]dropped down!", $Item))
        $game_variables[40] += 1
        pbMenu
    end
end