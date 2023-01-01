#this method is only called when the Rival battle is a double battle
def pbRivalDoubleBattle(name,nr)
    $MidBattle = [nil,:RIVAL_BATTLE_LAB]
    starterchoice = $game_variables[7]
    if $game_switches[96] == true
        rival = [:RIVAL1_F,:RIVAL2_M]
    else
        rival = [:RIVAL1_M,:RIVAL2_F]
    end
    TrainerBattle.dx_start([rival[0],name,starterchoice,rival[1],name,starterchoice],{:canlose => true, :outcome => 29},$MidBattle[nr])
end
#this method is only called when one of the Rivals is battled