#-------------------------------------------------------------------------------
# Special hold item on a map which includes battle in the name
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_item, :battle_map, proc { |_pkmn, _random_val|
  if $game_map.name.include?(_INTL("Battle"))
    # This array can be edited and extended to your hearts content.
    items = [:POKEBALL, :POKEBALL, :POKEBALL, :GREATBALL, :GREATBALL, :ULTRABALL]
    # Choose a random item from the items array, give the player 2 of the item
    # with the message "{1} is holding a round object..."
    next true if FollowingPkmn.item(items.sample, 2, _INTL("{1} is holding a round object..."))
  end
})
#-------------------------------------------------------------------------------
# Generic Item Dialogue
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_item, :regular, proc { |_pkmn, _random_val|
items = []
$bag.pockets.each_with_index do |pocket, index|
  next if index == 4 || index == 8  # Skip pocket 4 (TM's and HM's) and 8 (Key Items)

  pocket.each do |item, quantity|
    # next if item == :MASTERBALL #to exclude items
    items << item
  end
end
  # If no message or quantity is specified the default message is used and the quantity of item is 1
  item = items.sample
  next true if FollowingPkmn.item(item)
})
#-------------------------------------------------------------------------------
