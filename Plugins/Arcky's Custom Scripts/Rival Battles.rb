def main()
    @starterchoice = $game_variables[7]
    @rival = $game_switches[51] ? [:RIVAL1_F,:RIVAL2_M] : [:RIVAL1_M,:RIVAL2_F]
    @MidBattle = [nil, :RIVAL_BATTLE_LAB]
end

def pbRivalDoubleBattle(name,nr)
    main()
    TrainerBattle.dx_start([@rival[0],name,@starterchoice,@rival[1],name,@starterchoice],{:canlose => true, :outcome => 1},@MidBattle[nr])
end

def pbRivalPartnerBattle(name,rival)
    main()
    if rival == 1
        pbRegisterPartner(@rival[0],name,(@starterchoice + 12))
    else
        pbRegisterPartner(@rival[1],name,(@starterchoice + 12))
    end
end

def pbRivalSingleBattle(name,rival)
    main()
end