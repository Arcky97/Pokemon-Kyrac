#===============================================================================
# * Show Species Introdution - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It shows a picture with the pokémon
# species in a border, show a message with the name and kind, play it cry and
# mark it as seen in pokédex. Good to make the starter selection event.
#
#===============================================================================
#
# bo4p5687 (update)
#
#===============================================================================
#
# Call: show_image_pokemon(specie, gender, form, shiny, shadow, seen)
# 
# The specie is specie's number
# Seen: if set true, specie will show on pokedex
# Gender: 0 = male, 1 = female, 2 = genderless
# Form: set number of form such as 0, 1, 2, 3, etc
# Shiny: set true, it shows shiny pokemon
# Shadow: set true, it shows shadow pokemon
#
# Ex: 
# 'show_image_pokemon(:CHIKORITA)' shows Chikorita
# 'show_image_pokemon(:SHELLOS, 0, 1)' shows Shellos in East Sea form.
#
#===============================================================================
#===============================================================================
$iconwindow = nil #mod
def show_image_pokemon_retain_open(specie, gender = 0, form = 0, shiny = false, shadow = false, seen = true) #mod
    specie = GameData::Species.get(specie).id
  if seen
        $player.pokedex.set_seen(specie)
        $player.pokedex.register(specie, gender, form, shiny)
  end
  bitmap = GameData::Species.front_sprite_filename(specie, form, gender, shiny, shadow)
    GameData::Species.play_cry_from_species(specie, form)
  if bitmap # to prevent crashes
    used_bitmap = Bitmap.new(bitmap)
    used_bitmap = multiply_bitmap(used_bitmap, 2)
    $iconwindow = PictureWindow.new(used_bitmap)
    $iconwindow.x = (Graphics.width - $iconwindow.width) / 2
    $iconwindow.y = ((Graphics.height - 96) - $iconwindow.height) / 2
  end
end

def multiply_bitmap(bitmap, factor) #mod
  ret = Bitmap.new(bitmap.width*factor,bitmap.height*factor)
  ret.stretch_blt(Rect.new(0,0,ret.width,ret.height), bitmap, Rect.new(0,0.floor,bitmap.width,bitmap.height))
  return ret
end

def close_image_pokemon #mod
  return if !$iconwindow
  $iconwindow.dispose
  $iconwindow = nil
end