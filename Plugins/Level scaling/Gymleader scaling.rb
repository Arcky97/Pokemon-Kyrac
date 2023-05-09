Firstevo=40
Secondevo=40
Gymvar=32
Idlist=[19,20,21]
GymList=[[1,3,2],[1,3,2,20],[2,3,1],[2,3,1,17],[2,1,10],[2,1,3,2],[3,2,10],[3,2,1,18],[3,1,14],[3,1,2,12]]
def setNewStage(pokemon)	
    2.times do |evolvedTimes|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions(false)
      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      if !other_evolving_method   # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = evolvedTimes == 0 ? Firstevo : Secondevo

        if pokemon.level >= level
          if evolutions.length == 1     # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
          elsif evolutions.length > 1   # Species with multiple possible evolutions (the evolution is randomly defined)
            pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
          end
        end
      end
    end
end


def path(gymlist)
	pathlist=[]
	for i in gymlist
		pathlist.push(i[0...((i.length)-1)])	
	end
	return pathlist
end
      
EventHandlers.add(:on_trainer_load, :trainers,
  proc { |trainer|
   if trainer
      if trainer.name=="Brock" 
        if $trainer.badge_count == 0 && $game_switches[108] 
          for pkmn in trainer.party
            pkmn.level+=2
          end
        end
      end
      if $game_variables[56] >= 5 && $game_switches[55] #TrainerYacht Variable and is on Yacht Switch
        for pkmn in trainer.party
          pkmn.level+=2
          if $game_variables[56].between?(9, 15) #Defeated between 9 and 15 or more Trainers on the Yacht will increase 3 levels.
            pkmn.level+=1
          elsif $game_variables[56].between?(14, 20) #Defeated between 14 and 20 Trainers on the Yacht will increase 4 levels.
            pkmn.level+=2
          elsif $game_variables[56].between?(19, 30) #Defeated between 19 and 30 Trainers on the Yacht will increase 6 levels.
            pkmn.level+=4
          end 
          pkmn.reset_moves
          pkmn.calc_stats
        end
      end 
      if Idlist.include?($game_map.map_id) && $Trainer.badge_count>0
        if $Trainer.badge_count<3 
          list=$game_variables[Gymvar][0...$game_variables[Gymvar].length]
        end
        if $Trainer.badge_count>2 &&  $Trainer.badge_count<5
          list=$game_variables[Gymvar][3...$game_variables[Gymvar].length]
        end
        if $Trainer.badge_count>4 && $Trainer.badge_count<8
          list=$game_variables[Gymvar][5...$game_variables[Gymvar].length]
        end
        if $Trainer.badge_count>7 && $Trainer.badge_count<12
          list=$game_variables[Gymvar][8...$game_variables[Gymvar].length]
        end
        pathlist=path(GymList)
        for i in 0...pathlist.length
          if list==pathlist[i]
            for pkmn in trainer.party
              pkmn.level+= GymList[i][-1]
              setNewStage(pkmn)
              pkmn.reset_moves
              pkmn.calc_stats
            end
          end
        end
      end
   end
  }
)

=begin
$game_variables[40]=[]

$game_variables[40].push(gymnumber) if !$game_variables[40].include?(gymnumber)

=end