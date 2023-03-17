#IMPORTANT: All items need to be in all caps and start with a ":" just like how you would do it in an event the normal way.
#The Constants below holds all the items that'll NOT be used by the script.
#All items that have Pocket = 1 in the item list:
RIG_Pocket1 = []
#All items that have Pocket = 2 in the item list:
RIG_Pocket2 = []
#All items that have Pocket = 3 in the item list:
RIG_Pocket3 = [:MASTERBALL, :PREMIERBALL, :BEASTBALL]
#All items that have Pocket = 4 in the item list:
RIG_Pocket4 = [:HM01, :HM02, :HM03, :HM04, :HM05, :HM06]
#All items that have Pocket = 5 in the item list:
RIG_Pocket5 = []
#All items that have Pocket = 6 in the item list:
RIG_Pocket6 = []
#All items that have Pocket = 7 in the item list:
RIG_Pocket7 = []
#All items that have Pocket = 8 in the item list:
RIG_Pocket8 = []
#Even if though key items are usually never found in the overworld and mostly given by NPC's I still give you the option if you really want the player to find specific ones randomly.

#Below are a few options that you can set either true (on) or false (off).
#If this option is set to true, the chance the player will get an expensive item (mart price) is lower but this can be affected by other options.
RIG_ItemPrice = true

#If this option is set to true, the chance the player will get an expensive item (mart price) will increase with every badge they have.
RIG_Badges = true

#If this Constant is not empty, the chance the player will get an expensive item (mart price) will increase with every switch that is set to "ON" listed in the array. (switches that are still OFF will not increase the chance)
RIG_Switches = []

#If the options above are not enough yet for you then you can list below items to have a higher rarety, these will not be affected by the options above.
RIG_Ranges = [[20, 30], [15, 20], [10, 15], [5, 10], [2, 5], [1, 2]] 

RIG_Range_Items = [
                    [], #Range 1
                    [], #Range 2
                    [], #Range 3
                    [], #Range 4
                    [], #Range 5
                    []  #Range 6
                  ]

#Just one more, I promise:
#The Constant below holds the items you only want to be found once.
RIG_OneItemOnly = [:HELIXFOSSIL, :DOMEFOSSIL, :OLDAMBER, :ROOTFOSSIL, :CLAWFOSSIL, :SKULLFOSSIL, :ARMORFOSSIL, :COVERFOSSIL, :PLUMEFOSSIL, :JAWFOSSIL, :SAILFOSSIL, :FOSSILIZEDBIRD, :FOSSILIZEDFISH, :FOSSILIZEDDRAKE, :FOSSILIZEDDINO, #Fossils
                   :FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :MEADOWPLATE, :ICICLEPLATE, :FISTPLATE, :TOXICPLATE, :EARTHPLATE, :SKYPLATE, :MINDPLATE, :INSECTPLATE, :STONEPLATE, :SPOOKYPLATE, :DRACOPLATE, :DREADPLATE, :IRONPLATE, :PIXIEPLATE, #Plates for Arceus 
                   :VENUSAURITE, :CHARIZARDITEX, :CHARIZARDITEY, :BLASTOISINITE, :BEEDRILLITE, :PIDGEOTITE, :ALAKAZITE, :SLOWBRONITE, :GENGARITE, :KANGASKHANITE, :PINSIRITE, :GYARADOSITE, :AERODACTYLITE, :MEWTWONITEX, :MEWTWONITEY, #Mega Stones
                   :AMPHAROSITE, :STEELIXITE, :SCIZORITE, :HERACRONITE, :HOUNDOOMINITE, :TYRANITARITE, :SCEPTILITE, :BLAZIKENITE, :SWAMPERTITE, :GARDEVOIRITE, :SABLENITE, :MAWILITE, :AGGRONITE, :MEDICHAMITE, :MANECTITE, :SHARPEDONITE, 
                   :CAMERUPTITE, :ALTARIANITE, :BANETTITE, :ABSOLITE, :GLALITITE, :SALAMENCITE, :METAGROSSITE, :LATIASITE, :LATIOSITE, :LOPUNNITE, :GARCHOMITE, :LUCARIONITE, :ABOMASITE, :GALLADITE, :AUDINITE, :DIANCITE, :REDORB, :BLUEORB, 
                   :TM01, :TM02, :TM03, :TM04, :TM05, :TM06, :TM07, :TM08, :TM09, :TM10, :TM11, :TM12, :TM13, :TM14, :TM15, :TM16, :TM17, :TM18, :TM19, :TM20, :TM21, :TM22, :TM23, :TM24, :TM25, :TM26, :TM27, :TM28, :TM29, :TM30, :TM31, :TM32, :TM33, 
                   :TM34, :TM35, :TM36, :TM37, :TM38, :TM39, :TM40, :TM41, :TM42, :TM43, :TM44, :TM45, :TM46, :TM47, :TM48, :TM49, :TM50, :TM51, :TM52, :TM53, :TM54, :TM55, :TM56, :TM57, :TM58, :TM59, :TM60, :TM61, :TM62, :TM63, :TM64, :TM65, :TM66, 
                   :TM67, :TM68, :TM69, :TM70, :TM71, :TM72, :TM73, :TM74, :TM75, :TM76, :TM77, :TM78, :TM79, :TM80, :TM81, :TM82, :TM83, :TM84, :TM85, :TM86, :TM87, :TM88, :TM89, :TM90, :TM91, :TM92, :TM93, :TM94, :TM95, :TM96, :TM97, :TM98, :TM99, :TM100]               
#That's all for the options :D
#I think we are finished for now!

#Script:
def randomItem(pocket) #pocket is the only thing the script needs which is the number of the pocket to choose an item from.
    items = load_data("Data/items.dat")
    pocketItem = []
    for i in items.keys
        pocketItem.push(items[i]) if items[i].pocket == pocket
    end
    pbReceiveItem(pocketItem[rand(1...pocketItem.length)])
end