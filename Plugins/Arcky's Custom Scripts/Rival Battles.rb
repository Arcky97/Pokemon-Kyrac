#this method is only called when the Rival battle is a double battle
def main()
    @starterchoice = $game_variables[7]
    @rival = $game_switches[96] ? [:RIVAL1_F,:RIVAL2_M] : [:RIVAL1_M,:RIVAL2_F]
    @MidBattle = [nil, :RIVAL_BATTLE_LAB,:RIVAL1_TRAINER_SCHOOL_BATTLE, :RIVAL2_TRAINER_SCHOOL_BATTLE]
end

def pbRivalDoubleBattle(name,nr)
    main()
    TrainerBattle.dx_start([@rival[0],name,@starterchoice,@rival[1],name,@starterchoice],{:canlose => true, :outcome => 29},@MidBattle[nr])
end

def pbRivalPartnerBattle(name,rival)
    main()
    if rival == 1
        pbRegisterPartner(@rival[0],name,(@starterchoice + 12))
    else
        pbRegisterPartner(@rival[1],name,(@starterchoice + 12))
    end
end
#this method is only called when one of the Rivals is battled