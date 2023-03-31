#The 2 arguments required for the script to work are pocket and badge.
#Pocket is the number you see in the items.txt file that tells the game in which bag's pocket to put the item in, this is useful because then you can tell the script to randomly choose a ball item (pocket 3), healing item (pocket 2), TM item (pocket 4), etc
#Badge is used to lock the random item chosen to a limited selection (more explanation below).

#IMPORTANT: All items need to be in all caps and start with a ":" just like how you would do it in an event the normal way.
#The Constants below holds all the items that'll NOT be used by the script.
RIG_Excludes = [
                [1], #Items
                [2], #Medicine 
                [3, :MASTERBALL, :PREMIERBALL, :BEASTBALL], #Poké Balls
                [4, :HM01, :HM02, :HM03, :HM04, :HM05, :HM06], #TM's & HM's
                [5], #Berries
                [6, :STEELMAIL], #Mail
                [7], #Battle Items
                [8] #Key Items
               ]

#Even if key items are usually never found in the overworld and mostly given by NPC's I still give you the option if you really want the player to find specific ones randomly.

#Below you can add items and limit it to a badge number, I provided a whole list already so feel free to edit as wished. You can add as many badge locks as you want or even remove some. Just make sure the number is at the end of the array.
RIG_Limits = [
              [1, :REPEL, :ESCAPEROPE, :ICEHEAL, :BURNHEAL, :AWAKENING, :SUPERPOTION], 
              [3, :SUPERREPEL, :GREATBALL, :REVIVE], 
              [5, :HYPERPOTION, :ULTRABALL, :FULLHEAL], 
              [7, :MAXPOTION], 
              [8, :FULLRESTORE]
             ]
#This might require a bit more clearification: For example you called the script doing "randomItem(3, 1)" the script will choose an item from all items with the pocket number 3 (ball items) and all items that have a badge lock 1.
#What this means is that items with a badge lock higher than 1 will not be chosen).

#Just one more, I promise:
#The Constant below holds the items you only want to be found once. ()
RIG_OneItemOnly = [[1, :HELIXFOSSIL, :DOMEFOSSIL, :OLDAMBER, :ROOTFOSSIL, :CLAWFOSSIL, :SKULLFOSSIL, :ARMORFOSSIL, :COVERFOSSIL, :PLUMEFOSSIL, :JAWFOSSIL, :SAILFOSSIL, :FOSSILIZEDBIRD, :FOSSILIZEDFISH, :FOSSILIZEDDRAKE, :FOSSILIZEDDINO, #Fossils
                    :FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :MEADOWPLATE, :ICICLEPLATE, :FISTPLATE, :TOXICPLATE, :EARTHPLATE, :SKYPLATE, :MINDPLATE, :INSECTPLATE, :STONEPLATE, :SPOOKYPLATE, :DRACOPLATE, :DREADPLATE, :IRONPLATE, :PIXIEPLATE, #Plates for Arceus 
                    :VENUSAURITE, :CHARIZARDITEX, :CHARIZARDITEY, :BLASTOISINITE, :BEEDRILLITE, :PIDGEOTITE, :ALAKAZITE, :SLOWBRONITE, :GENGARITE, :KANGASKHANITE, :PINSIRITE, :GYARADOSITE, :AERODACTYLITE, :MEWTWONITEX, :MEWTWONITEY, #Mega Stones
                    :AMPHAROSITE, :STEELIXITE, :SCIZORITE, :HERACRONITE, :HOUNDOOMINITE, :TYRANITARITE, :SCEPTILITE, :BLAZIKENITE, :SWAMPERTITE, :GARDEVOIRITE, :SABLENITE, :MAWILITE, :AGGRONITE, :MEDICHAMITE, :MANECTITE, :SHARPEDONITE, 
                    :CAMERUPTITE, :ALTARIANITE, :BANETTITE, :ABSOLITE, :GLALITITE, :SALAMENCITE, :METAGROSSITE, :LATIASITE, :LATIOSITE, :LOPUNNITE, :GARCHOMITE, :LUCARIONITE, :ABOMASITE, :GALLADITE, :AUDINITE, :DIANCITE, :REDORB, :BLUEORB], 
                   [4, :TM01, :TM02, :TM03, :TM04, :TM05, :TM06, :TM07, :TM08, :TM09, :TM10, :TM11, :TM12, :TM13, :TM14, :TM15, :TM16, :TM17, :TM18, :TM19, :TM20, :TM21, :TM22, :TM23, :TM24, :TM25, :TM26, :TM27, :TM28, :TM29, :TM30, :TM31, :TM32, :TM33, 
                    :TM34, :TM35, :TM36, :TM37, :TM38, :TM39, :TM40, :TM41, :TM42, :TM43, :TM44, :TM45, :TM46, :TM47, :TM48, :TM49, :TM50, :TM51, :TM52, :TM53, :TM54, :TM55, :TM56, :TM57, :TM58, :TM59, :TM60, :TM61, :TM62, :TM63, :TM64, :TM65, :TM66, 
                    :TM67, :TM68, :TM69, :TM70, :TM71, :TM72, :TM73, :TM74, :TM75, :TM76, :TM77, :TM78, :TM79, :TM80, :TM81, :TM82, :TM83, :TM84, :TM85, :TM86, :TM87, :TM88, :TM89, :TM90, :TM91, :TM92, :TM93, :TM94, :TM95, :TM96, :TM97, :TM98, :TM99, :TM100],
                   [6, :GRASSMAIL, :FLAMEMAIL, :BUBBLEMAIL, :BLOOMMAIL, :SPACEMAIL, :AIRMAIL, :BRICKMAIL, :MOSAICMAIL, :HEARTMAIL]
                 ]               
#That's all for the options :D
#I think we are finished for now!

#Script:
def randomItem(pocket, badge) #pocket and badge are the only thing the script needs which is the number of the pocket to choose an item from.
    items = load_data("Data/items.dat")
    pocketItem = items.keys.find_all{|i| next items[i].pocket == pocket}
    $itemsFoundAmount = [] if $itemsFoundAmount == nil
    $itemsFound = [] if $itemsFound == nil
    item = nil
    while !item || ($itemsFound.include?(item) && RIG_OneItemOnly[2].include?(item) || RIG_Excludes[5].include?(item))
        item = pocketItem[rand(0...pocketItem.length)]
    end
    echoln(RIG_Excludes[5].include?(item))
    arrayLineFound = $itemsFoundAmount.find{|arrayLine| arrayLine[0] == item}
    if arrayLineFound
        arrayLineFound[1] += 1
    else
       $itemsFoundAmount.push([item, 1]) 
       $itemsFound.push(item)   
    end
    pbReceiveItem(item)
    letstrysomething(pocket)
end