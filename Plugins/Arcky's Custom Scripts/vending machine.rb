def pbVendingMachine(name,number,items)
    discount = (100 - number).to_f / 100
    pbMessage(_INTL("Look! It's a Vending Machine!"))
    pbMenu(name, discount, items)
end

def pbMenu(input, discount, itemlist)
    choice = pbMessage(_INTL("Which {1} would you like to buy?\\G", input), 
    (0...itemlist.size).to_a.map{|i| 
      next _INTL("{1} - ${2}", GameData::Item.get(itemlist[i]).name, ((GameData::Item.get(itemlist[i]).price) * discount).round)
    }, -1)
    return if 0>choice || choice>7
    if $player.money < ((GameData::Item.get(itemlist[choice]).price) * discount).round
      pbMessage(_INTL("\\GYou don't have enought \\c[3]money\\c[0]!"))
      return
    end
    if !$bag.can_add?(itemlist[choice])
      pbMessage(_INTL("\\GYou have no room left in your Bag."))
      return
    end
    $player.money -= ((GameData::Item.get(itemlist[choice]).price) * discount).round
    $game_variables[39] += 1
    item = GameData::Item.get(itemlist[choice]).name
    numb = 0
    if random(numb, item) == 5
        return if onItemStuck(numb, item)
    else
        start = letterChecker(item)
        pbMessage(_INTL("\\se[Vending machine sound]\\G{1} \\c[1]{2} \\c[0]dropped down!",start, item))
    end
    $bag.add(itemlist[choice])
    bonus(choice, item, itemlist) if random(numb, item) == 5
    pbMenu(input, discount, itemlist)
end

def letterChecker(item)
    if item.starts_with_vowel?
        word = "An"
    elsif item.last == "s" 
        word = "Some"
    else
        word = "A"
    end
end


def random(numb, item)
    return numb = numb.rand(1..10)
end

def bonus(choice, item, itemlist)
    if $bag.can_add?(itemlist[choice])
        $bag.add(itemlist[choice])
        if item.last == "s"
            start = "Some more"
        end
        pbMessage(_INTL("\\se[Vending machine sound]\\GBonus! {1} \\c[1]{2} \\c[0]dropped down!",start, item))
        $game_variables[40] += 1
    end
end

def onItemStuck(numb, item)
    kick = pbMessage(_INTL("\\GOh no! Your \\c[1]{1} \\c[0]got stuck! Do you want to try to kick the machine?", item),
        [_INTL("Yes"),_INTL('No')], -1)
    if kick != 0
        pbMessage(_INTL("\\GLooks like you don't mind wasting your money!"))
        return true
    end
    if random(numb, item) == 5
        pbMessage(_INTL("\\GYour kick didn't work and you lost your \\c[1]{1} \\c[0]!", item))
        return true
    end
    pbMessage(_INTL("\\GYour kick worked and the \\c[1]{1} \\c[0]dropped down!", item))
    return false
end