def pbVendingMachine(name, var1, var2, var3, var4, items, discount = 0, multyBuy = false, min = 1, max = 10)
    pbMessage(_INTL("Look! It's a Vending Machine!"))
    @input = name
    @itemsBought = var1
    @itemsWon = var2
    @itemsStuck = var3
    @itemsLost = var4
    @itemList = items
    @multyBuy = multyBuy
    @multyBuyMin = min
    @multyBuyMax = max
    @discount = (100 - discount).to_f / 100
    echoln(@discount)
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
    $game_variables[@itemsBought] += @qty
    @itemPrice = (((GameData::Item.get(@itemList[@choice]).price) * @discount).round) * @qty
    if $player.money < @itemPrice
      pbMessage(_INTL("\\GYou don't have enough \\c[3]money\\c[0]!"))
      return
    end
    if !$bag.can_add?(@itemList[@choice], @qty)
      pbMessage(_INTL("\\GYou have no room left in your Bag."))
      return
    end
    pbSEPlay("Mart buy item")
    $player.money -= @itemPrice
    @bonusPercentage = maxLevel(10)
    itemStuckCalculator()
    $bag.add(@itemList[@choice], @qty)
    return if @qty == 0
    bonus() if ((rand(1..1000))*0.1).round(1) <= @bonusPercentage
    pbMenu()
end

def quantity()
    params = ChooseNumberParams.new
    params.setRange(@multyBuyMin, @multyBuyMax)
    params.setInitialValue(@multyBuyMin)
    params.setCancelValue(@multyBuyMin)
    return @qty = pbMessageChooseNumber(_INTL("\\GHow many {1} do you want to buy?", @item), params)
end

def itemStuckCalculator()
    @percentageItemStuck = random(@qty)
    @percentageOnMaxLevel = maxLevel(65)
    @counter = countItemPercentage(@percentageItemStuck)
    if @qty == 1
        if @percentageItemStuck[0] > @percentageOnMaxLevel
            onItemStuck()
        else
            pbMessage(_INTL("\\se[Vending machine sound]\\G{1} \\c[1]{2} \\c[0]dropped down!",letterChecker(), @item))
        end
    else 
        if @counter[0] != 0
            onItemStuck()
        else
            pbMessage(_INTL("\\se[Vending machine sound]\\G{1} \\c[1]{2} \\c[0]dropped down!",@qty, itemname = @counter[1] > 1 ? @items : @item))
        end
    end
end

def random(qty)
    return random = Array.new(qty) {((rand(1..1000))*0.1).round(1)}
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
        $game_variables[@itemsWon] += 1
    end
end

def noKick(qty = @qty)
    pbMessage(_INTL("\\GYou lost {1} \\c[1]{2} \\c[0]and \\c[3]${3}\\c[0]!", qty, @itemNameStuck, @itemPrice))
    $game_variables[@itemsLost] += qty
    @qty = 0
end

def yesKick(qty = @qty)
    if ((rand(1..1000))*0.1).round(1) > maxLevel(65)
        pbMessage(_INTL("\\GYour kick didn't work and you lost your {1} \\c[1]{2} \\c[0]and \\c[3]${3}\\c[0]!", qty, @items, @itemPrice))
        $game_variables[@itemsLost] += qty
    else 
        pbMessage(_INTL("\\se[Vending machine sound]\\GYour kick worked and {1} \\c[1]{2} \\c[0]dropped down!", qty, @items))
        @bonusPercentage = maxLevel(20)
    end
end

def onItemStuck()
    if @qty == 1
        kick = pbMessage(_INTL("\\GOh no! Your \\c[1]{1} \\c[0]got stuck! Do you want to try to kick the machine?", @item),
            [_INTL("Yes"),_INTL("No")], -1)
        $game_variables[@itemsStuck] += 1
        if kick != 0
            pbMessage(_INTL("\\GLooks like you don't mind wasting your money (\\c[3]${1}\\c[0])!", @itemPrice))
            $game_variables[@itemsLost] += 1
            @qty = 0
            return true
        end
        random = random(@qty)
        if random[0] > maxLevel(65)
            pbMessage(_INTL("\\GYour kick didn't work and you lost your \\c[1]{1} \\c[0]and \\c[3]${2}\\c[0]!", @item, @itemPrice))
            $game_variables[@itemsLost] += 1
            @qty = 0
            return true
        end
        pbMessage(_INTL("\\se[Vending machine sound]\\GYour kick worked and the \\c[1]{1} \\c[0]dropped down!", @item))
        return false
    else
        @itemNameStuck = @counter[0] > 1 ? @items : @item
        @itemNameFree = @counter[1] > 1 ? @items : @item
        increase = @percentageOnMaxLevel / 2
        decrease = @percentageOnMaxLevel / 4
        random = @counter[1] != 0 ? rand(1..10) : 11
        if random >= 1 || random <=5 #items get stuck first then remaining items drop down
            for i in 1...@counter[1]
                increase = @percentageOnMaxLevel + increase / 2
            end
            for i in 1...@counter[0]
                decrease = @percentageOnMaxLevel - decrease / 4
            end
            @itemUnstuck = increase - decrease
            if ((rand(1..1000))*0.1).round(1) <= @itemUnstuck
                pbMessage(_INTL("\\GOh no! {1} \\c[1]{2} \\c[0]got stuck! But the other {3} \\c[1]{4} \\c[0]got them dropping down!", @counter[0], @itemNameStuck, @counter[1], @itemNameFree))
                $game_variables[@itemsStuck] += @counter[0]
            else
                pbMessage(_INTL("\\GOh no! {1} \\c[1]{2} \\c[0]got stuck! The other {3} \\c[1]{4} \\c[0]failed to get the {1} \\c[1]{2} \\c[0]dropping down", @counter[0], @itemNameStuck, @counter[1], @itemNameFree))
                $game_variables[@itemsStuck] += @qty
                kick = pbMessage(_INTL("\\GDo you want to kick the machine to get them all out?"),
                [_INTL("Yes"),_INTL('No')], -1)
                action = kick != 0 ? noKick() : yesKick()
            end
        elsif random >= 6 || random <=10    
            kick = pbMessage(_INTL("\\G{1} \\c[1]{2} \\c[0]dropped down! But {3} \\c[1]{4} \\c[0]got stuck! Do you want to kick the machine to get them out?!", @counter[1], @itemNameFree, @counter[0], @itemNameStuck),
                [_INTL("Yes"),_INTL('No')], -1)
            $game_variables[@itemsLost] += @counter[0]
            @itemPrice = (@itemPrice / @qty) * @counter[0]
            @qty -= @counter[0]
            action = kick != 0 ? noKick(@counter[0]) : yesKick(@counter[0])
        else # random == 11 which means all items got stuck
            kick = pbMessage(_INTL("\\G{1} \\c[1]{2} \\cOh no, all {3} \\c[1]{4} \\c[0]got stuck! Do you want to kick the machine to get them out?!", @counter[1], @itemNameFree, @counter[0], @itemNameStuck),
                [_INTL("Yes"),_INTL('No')], -1)
            $game_variables[@itemsLost] += @counter[0]
            action = kick != 0 ? noKick(@counter[0]) : yesKick()
        end
    end
end