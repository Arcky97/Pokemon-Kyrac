def pbVendingMachine(name, number, items, multyBuy = false)
    @discount = (100 - number).to_f / 100
    pbMessage(_INTL("Look! It's a Vending Machine!"))
    @input = name
    @itemList = items
    @multyBuy = multyBuy   
    pbMenu()
end

def pbMenu()
    @choice = pbMessage(_INTL("Which {1} would you like to buy?\\G", @input), 
    (0...@itemList.size).to_a.map{|i| 
      next _INTL("{1} - ${2}", GameData::Item.get(@itemList[i]).name, ((GameData::Item.get(@itemList[i]).price) * @discount).round)
    }, -1)
    return if 0 > @choice 
    @item = GameData::Item.get(@itemList[@choice]).name
    @items = GameData::Item.get(@itemList[@choice]).name_plural 
    @qty = @multyBuy ? quantity() : 1
    @itemPrice = (((GameData::Item.get(@itemList[@choice]).price) * @discount).round) * @qty
    if $player.money < @itemPrice
      pbMessage(_INTL("\\GYou don't have enought \\c[3]money\\c[0]!"))
      return
    end
    if !$bag.can_add?(@itemList[@choice], @qty)
      pbMessage(_INTL("\\GYou have no room left in your Bag."))
      return
    end
    pbSEPlay("Mart buy item")
    $player.money -= @itemPrice
    itemStuckCalculator()
    $bag.add(@itemList[@choice], @qty)
    #bonus() if random() <= maxLevel(10)
    pbMenu()
end

def quantity()
    params = ChooseNumberParams.new
    params.setRange(1, 10)
    params.setInitialValue(1)
    params.setCancelValue(0)
    return @qty = pbMessageChooseNumber(_INTL("\\GHow many {1} do you want to buy?", @item), params)
end

def itemStuckCalculator()
    percentageItemStuck = random()
    @percentageOnMaxLevel = maxLevel(65)
    @counter = countItemPercentage(percentageItemStuck)
    if @qty == 1
        @start = letterChecker()
        action = percentageItemStuck[0] > @percentageOnMaxLevel ? onItemStuck() : pbMessage(_INTL("\\se[Vending machine sound]\\G{1} \\c[1]{2} \\c[0]dropped down!",@start, @item)) 
    else 
        onItemStuck() if @counter[0] !=0 
        pbMessage(_INTL("\\se[Vending machine sound]\\G{1} \\c[1]{2} \\c[0]dropped down!",@start, itemname = @counter[1] > 1 ? @items : @item)) if @counter[0] == 0
    end
end

def random()
    return random = Array.new(@qty) {((rand(1..1000))*0.1).round(1)}
end

def maxLevel(basePercentage)
    maxLevel = 0
    for i in 0...$player.party.length
        next if maxLevel > $player.party[i].level
        maxLevel = $player.party[i].level
    end
    return percentage = (maxLevel * 0.2) + basePercentage
end

def countItemPercentage(itemStuck)
    cntStuck, cntFree = 0, 0
    counter = []
    for i in 0...itemStuck.length
        cntStuck += 1 if itemStuck[i] > @percentageOnMaxLevel
        cntFree += 1 if itemStuck[i] <= @percentageOnMaxLevel
    end
    return counter.push(cntStuck, cntFree)
end

def letterChecker()
    if @item.starts_with_vowel?
        word = "An"
    elsif @item.last == "s" 
        word = "Some"
    else
        word = "A"
    end
end

def bonus()
    if $bag.can_add?(@itemList[@choice])
        $bag.add(@itemList[@choice])
        start = @item.last == "s" ? "Some more" : "Another"
        pbMessage(_INTL("\\se[Vending machine sound]\\GBonus! {1} \\c[1]{2} \\c[0]dropped down!",start, @item))
        $game_variables[40] += 1
    end
end

def onItemFree()
    
end

def onItemStuck()
    if @qty == 1
        kick = pbMessage(_INTL("\\GOh no! Your \\c[1]{1} \\c[0]got stuck! Do you want to try to kick the machine?", @item),
            [_INTL("Yes"),_INTL("No")], -1)
        if kick != 0
            pbMessage(_INTL("\\GLooks like you don't mind wasting your money (\\c[3]${1}\\c[0])!", @itemPrice))
            return true
        end
        random = random()
        if random[0] > maxLevel(65)
            pbMessage(_INTL("\\GYour kick didn't work and you lost your \\c[1]{1} \\c[0]and \\c[3]${2}\\c[0]!", @item, @itemPrice))
            return true
        end
        pbMessage(_INTL("\\se[Vending machine sound]\\GYour kick worked and the \\c[1]{1} \\c[0]dropped down!", @item))
        return false
    else
        random = @counter[0] != 0 || @counter[1] != 0 ? rand(1..2) : 3
        if random == 1 #items get stuck first then remaining items drop down
            pbMessage(_INTL("\\GOh no! {1} \\c[1]{2} \\c[0]got stuck! But the other {3} \\c[1]{4} \\c[0]got them dropping down!", @counter[0], itemname = @counter[0] > 1 ? @items : @item, @counter[1], itemname = @counter[1] > 1 ? @items : @item))
            return false
        elsif random == 2    
            kick = pbMessage(_INTL("\\G{1} \\c[1]{2} \\c[0]dropped down! But {3} \\c[1]{4} \\c[0]got stuck! Do you want to kick the machine to get them out?!", @counter[1], itemname = @counter[1] > 1 ? @items : @item, @counter[0], itemname = @counter[0] > 1 ? @items : @item),
                [_INTL("Yes"),_INTL('No')], -1)
            if kick != 0
                return true
            end
            kickWorked = countItemPercentage(random())
            if kickWorked[0] > kickWorked[1]
                pbMessage(_INTL("\\GYour kick didn't work and you lost your {1}{2} \\c[1]{3} \\c[0]and \\c[3]${4}\\c[0]!", @counter[0], @item, @itemPrice))
                return true
            else 
                pbMessage(_INTL("\\se[Vending machine sound]\\GYour kick worked and {1} \\c[1]{2} \\c[0]dropped down!", @counter[0], @items))
                return false
            end
        else #random == 3 items will first drop down and then remaining items will get stuck
            pbMessage(_INTL("\\GOh no! The \\c[1]{2} \\c[0]dropped down!", @items)) if counter[0] == 0
            kick = pbMessage(_INTL("\\GOh no! The \\c[1]{2} \\c[0]got stuck! Do you want to kick the machine to get them out?", @items),
                [_INTL("Yes"),_INTL("no")], -1) if counter[1] == 0
            if kick != 0
                pbMessage(_INTL("\\GLooks like you don't mind wasting your money (\\c[3]${1}\\c[0])!", @itemPrice))
                return true
            end
            random = random()
            if random[0] > maxLevel(65)
                pbMessage(_INTL("\\GYour kick didn't work and you lost your \\c[1]{1} \\c[0]and \\c[3]${2}\\c[0]!", @item, @itemPrice))
                return true
            end
            pbMessage(_INTL("\\se[Vending machine sound]\\GYour kick worked and the \\c[1]{1} \\c[0]dropped down!", @item))
            return false
        end
    end
end