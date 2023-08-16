module QuestModule
#Prologue Arc 1: Leaving Home!
  #Story Quest 1
  Quest1 = {
    :ID => "1",
    :Name => "Getting ready!",
    :QuestGiver => "Your Mother",
    :Stage1 => "Let's go get breakfast!",
    :Stage2 => "Talk to your mother.",
    :Location => "Your house's F1",
    :QuestDescription1 => "Use the elevator to get to the F1 of the house and get your breakfast!",
    :QuestDescription2 => "Before you can leave on your Journey, you should talk to your Mother and get the necessarily equipment to start with.",
    :RewardString => "Now you feel ready to start your Journey!"
  }

  #Side Quest 1
  Quest2 = {
    :ID => "2",
    :Name => "Hit the Plants!",
    :QuestGiver => "Unknown",
    :Stage1 => "Hit a Plant!",
    :Stage2 => "Hit more plants!",
    :Stage3 => "Hit even more plants!",
    :Location1 => "Anywhere",
    :QuestDescription => "Hit as many plants as you can! Any plant counts, in houses, buildings, yachts, PokéCenters, Marts, etc...",
    :RewardString => "A bunch of plants being mad."
  }

  #Story Quest 2
  Quest3 = {
    :ID => "3",
    :Name => "The journey begins!",
    :QuestGiver => "Your Mother",
    :Stage1 => "Go to the Yacht!",
    :Stage2 => "Talk to the Guards.",
    :Stage3 => "Find the evidence.",
    :Stage4 => "Talk to the Guards again.",
    :Stage5 => "Go to the Yacht!",
    :Location => "The Dock, South of your House.",
    :Location2 => "The Front Gate of Your Home.",
    :Location3 => "Your Home's Garden's Maze.",
    :Location4 => "The Front Gate of Your Home.",
    :QuestDescription1 => "Even if you lived here your whole life, you know very little about the Kyrac Region. You'll be going to the first City by using your Father's Yacht.",
    :QuestDescription => "Julia noticed there's something odd about the guards this morning, go talk to them to find out what's wrong.",
    :QuestDescription5 => "Now that you found the evidence to proof the Guards have been drunk, you should let your mother know by phone. How? Well there should be a phone on the Yacht perhaps. So get going and get on the Yacht!",   
    :RewardString => "You are now a pro-detective! Next step? Becoming a pro in Pokémon Battling!"
  }

  #Side Quest 2
  Quest4 = {
    :ID => "4",
    :Name => "The a-Maze-ing Quest!",
    :QuestGiver => "Yourself",
    :Stage1 => "Find all the items.",
    :Location1 => "Your Home's Garden.",
    :QuestDescription => "Go through the maze and try to find all off the hidden items. (10 in total) ",
    :RewardString => "A lot of useful items."
  }

#Prologue Arc 2: The Yacht!
  #Story Quest 3
  Quest5 = {
    :ID => "5",
    :Name => "Getting your Starter!",
    :QuestGiver => "Father's Assistant.",
    :Stage1 => "Meet up in the lab!",
    :Stage2 => "Choose your Starter!",
    :Stage3 => "Battle your Rivals!",
    :Location => "Prof Oak's Lab.",
    :QuestDescription => "It is time to choose your official Starter Pokémon and challenge your Rivals to a Pokémon Battle.",
    :RewardString => "You got your Official Starter Pokémon, how cool is that?"
  }

  #Story Quest 4
  Quest6 = {
    :ID => "6",
    :Name => "Explore the Yacht!",
    :QuestGiver => "Prof. Oak",
    :Stage1 => "Explore the Yacht!",
    :Location1 => "The Yacht",
    :QuestDescription => "Explore the Yacht the way you want! Talk to both your rivals, defeat at least 5 trainers and receive the Oldrod from the fisherman.",
    :RewardString => "You'll arrive in Hester City."
  }
  
#Chapter 1 Arc 1: The FPI!
  #Story Quest 5
  Quest7 = {
    :ID => "7",
    :Name => "The FPI at the Trainer School!",
    :QuestGiver => "Prof. Oak",
    :Stage1 => "Go to the Trainer School!",
    :Stage2 => "Fight the FPI Grunts!",
    :Stage3 => "Find the FPI Boss.",
    :Stage4 => "Enter the hidden room.",
    :Location1 => "Hester City",
    :Location2 => "Trainer School",
    :Location3 => "Trainer School's Library",
    :Location4 => "Trainer School's Hidden Room",
    :QuestDescription1 => "The FPI is after something in the Trainer school and is keeping the students and teacher as a hostage.",
    :QuestDescription2 => "Prepare yourself and head inside the Trainer School to face the FPI Grunts alongside your Rivals.",
    :QuestDescription3 => "The FPI Boss is inside the Trainer School Library, go find him!",
    :QuestDescription4 => "Enter the Hidden Room and stop the FPI Boss!",
    :RewardString => "A gift from \\v[45]."
  }

  #Story Quest 6
  Quest8 = {
    :ID => "8",
    :Name => "The Dark Type Gym!",
    :QuestGiver => "Prof. Oak",
    :Stage1 => "Talk to Prof. Oak.",
    :Location1 => "Prof Oak's lab on the Yacht.",
    :QuestDescription1 => "Prof. Oak wants to talk to you about something in person, let's have a listen to what he has to say.",
    :RewardString => "nothing yet"
  }

#Chapter 1 Arc 2: The First Gym!  
  Quest11 = {
    :ID => "11",
    :Name => "The Dark Type Gym!",
    :QuestGiver => "Yourself",
    :Stage1 => "Find another way into the Gym in Hester City!",
    :Location1 => "Hester City",
    :QuestDescription => "The Gym in Hester City seems to be closed from the outside. Maybe talking to the people in Hester City might help you find a way into the gym.",
    :RewardString => "You got to fight the Gym Leader, got his badge and a TM."
  }

  Quest300 = {
    :ID => "300",
    :Name => "Defeat the Mad Plants!",
    :QuestGiver => "Unknown",
    :Stage1 => "Gotta defeat them all!",
    :Location1 => "Plants HQ.",
    :QuestDescription => "Because you hit the plants so many times all around the region, you'll now have to face them in an actual Pokémon battle!",
    :RewardString => "A nice plant for your bedroom!"
  }
end