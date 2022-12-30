#===============================================================================
# * Trainers' Species Usage - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It prints all species usage by
# trainers, sorted by occurrences, divided by Pokédex and type. This data is 
# useful to balance pokémon usage.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main OR convert into a plugin.
#
#== HOW TO USE =================================================================
#
# At debug menu, in "Other Options", select "Print Trainers' Species Usage"
# and check the generated files.
#
#===============================================================================

if !PluginManager.installed?("Trainers Species Usage")
  PluginManager.register({                                                 
    :name    => "Trainers Species Usage",                                        
    :version => "1.0",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=477929",             
    :credits => "FL"
  })
end

module TrainersSpeciesUsage
  # File path. %s will replaced by Pokédex name.
  TXT_FILE_PATH = "Trainers Species Usage/%s"

  # Ignore below trainers.
  # If the array is empty or is nil, ignores all trainers of trainer type.
  TRAINER_TYPE_EXCEPTIONS = {
    :RIVAL1_F => [],
    :RIVAL1_M => [],
    :RIVAL2_F => [],
    :RIVAL2_M => [],
    :CHAMPION => [],
  }

  # Ignores below pokémon species.
  SPECIES_EXCEPTIONS = [
    :ARTICUNO,:ZAPDOS,:MOLTRES,:RAIKOU,:ENTEI,:SUICUNE,:REGIROCK,:REGICE,
    :REGISTEEL,:UXIE,:MESPRIT,:AZELF,:COBALION,:TERRAKION,:VIRIZION,:TORNADUS,
    :THUNDURUS,:KELDEO,:TAPUKOKO,:TAPULELE,:TAPUBULU,:TAPUFINI,:NIHILEGO,
    :BUZZWOLE,:PHEROMOSA,:XURKITREE,:CELESTEELA,:KARTANA,:GUZZLORD,:STAKATAKA,
    :BLACEPHALON,:REGIELEKI,:REGIDRAGO,:GLASTRIER,:SPECTRIER,
    :MEW,:CELEBI,:LATIAS,:LATIOS,:JIRACHI,:DEOXYS,:HEATRAN,:REGIGIGAS,
    :CRESSELIA,:MANAPHY,:DARKRAI,:SHAYMIN,:VICTINI,:LANDORUS,:MELOETTA,
    :GENESECT,:DIANCIE,:HOOPA,:VOLCANION,:NECROZMA,:MAGEARNA,:MARSHADOW,
    :ZERAORA,:ZARUDE,
    :PHIONE,:COSMOG,:COSMOEM,:CALYREX,:MELTAN,:MELMETAL,
    :MEWTWO,:LUGIA,:HOOH,:GROUDON,:KYOGRE,:RAYQUAZA,:PALKIA,:DIALGA,:GIRATINA,
    :RESHIRAM,:ZEKROM,:KYUREM,:XERNEAS,:YVELTAL,:ZYGARDE,:SOLGALEO,:LUNALA,
    :ZACIAN,:ZAMAZENTA,:ETERNATUS,
    :ARCEUS,
  ]

  # The below pokémon form/ids as treated as separated pokémon. Otherwise treats
  # forms as same pokémon species.
  FORMS_TO_COUNT = [
    :WORMADAM_1,:WORMADAM_2,
    :MEOWSTIC_1,
    :ORICORIO_1,:ORICORIO_2,:ORICORIO_3,
    :LYCANROC_1,:LYCANROC_2,
    :INDEEDEE_1,
    :TOXTRICITY_1,
    :RATTATA_1,:RATICATE_1,:RAICHU_1,:SANDSHREW_1,:SANDSLASH_1,:VULPIX_1, 
    :NINETALES_1,:DIGLETT_1,:DUGTRIO_1,:MEOWTH_1,:PERSIAN_1,:GEODUDE_1,
    :GRAVELER_1,:GOLEM_1,:GRIMER_1,:MUK_1,:EXEGGUTOR_1,:MAROWAK_1,
    :MEOWTH_2,:PONYTA_1,:RAPIDASH_1,:FARFETCHD_1,:WEEZING_1,:MRMIME_1,
    :CORSOLA_1,:ZIGZAGOON_1,:LINOONE_1,:DARUMAKA_2,:DARMANITAN_2,:YAMASK_1,
    :STUNFISK_1,:SLOWPOKE_1,:SLOWBRO_1,:SLOWKING_1,
  ]

  # List pokémon by type.
  FILTER_BY_TYPE = true

  class Row
    attr_reader :species
    attr_reader :species_data
    attr_reader :occurrences
    attr_reader :dex_index

    include Comparable

    def <=>(other)
      return (
        @occurrences <=> other.occurrences
      ) * 10_000 + @dex_index <=> other.dex_index
    end

    def initialize(species, occurrences, dex_index)
      @species = species
      @species_data = GameData::Species.get(@species)
      @occurrences = occurrences
      @dex_index = dex_index
    end

    def species_types
      @species_data.types
    end

    def display_name
      ret = @species_data.name
      ret+=" #{@species_data.form}" if @species_data.form>0
      return ret
    end

    def string
      return "#{"%04d" % @dex_index} #{@occurrences} #{display_name}\n"
    end
  end

  def self.generate_txt_for_every_dex
    validate
    occurrences_by_species = get_occurrences_by_species
    for dex_index in -1...(Settings.pokedex_names.size-1)
      generate_txt(get_dex_name(dex_index), get_dex_string(
        get_table(occurrences_by_species, get_dex_list(dex_index))
      ))
    end
  end

  # Raise an error for invalid species/trainer types
  def self.validate
    validate_pbs(SPECIES_EXCEPTIONS, GameData::Species)
    validate_pbs(FORMS_TO_COUNT, GameData::Species)
    validate_pbs(TRAINER_TYPE_EXCEPTIONS.keys, GameData::TrainerType)
  end

  def self.validate_pbs(array, pbs)
    wrong_value = array.find{|value| !pbs.exists?(value)}
    if wrong_value
      raise ArgumentError, "#{wrong_value} isn't a valid #{pbs} value!" 
    end
  end

  def self.get_dex_string(table)
    ret = ""
    if FILTER_BY_TYPE
      ret = get_per_type_string(table) + "\n# ALL\n"
    end
    ret += get_table_string(table)
    return ret
  end

  def self.get_per_type_string(table)
    ret = ""
    for type in get_all_valid_types
      ret += "\n# #{type.name}\n"
      ret += get_table_string(table.find_all{|row| 
        row.species_types.include?(type.id)
      })
    end
    return ret
  end

  def self.get_table_string(table)
    return table.map{|row| row.string}.join
  end

  def self.get_occurrences_by_species
    ret ={}
    for key in GameData::Species.keys
      ret[key] = 0
    end
    for inner_hash in get_trainers_double_hash.values
      for species_array in inner_hash.values
        for species in species_array
          ret[species]+= 1
        end
      end
    end
    merge_forms!(ret)
    remove_exception_species!(ret)
    return ret
  end

  # Return a hash per trainer type with another hash per trainer name with
  # occurrences. This way, doesn't count a same pokémon repeated on different 
  # trainer versions.
  def self.get_trainers_double_hash
    ret = {}
    GameData::Trainer.each do |trainer|
      if TRAINER_TYPE_EXCEPTIONS.has_key?(trainer.trainer_type)
        array = TRAINER_TYPE_EXCEPTIONS[trainer.trainer_type]
        next if !array || array.empty? || array.include?(trainer.real_name)
      end
      ret[trainer.trainer_type] ||= {}
      ret[trainer.trainer_type][trainer.real_name] ||= []
      for pokemon_entry in trainer.pokemon
        ret[trainer.trainer_type][trainer.real_name].push(
          GameData::Species.get_species_form(
            pokemon_entry[:species], pokemon_entry[:form] || 0
          ).id
        )
      end
      ret[trainer.trainer_type][trainer.real_name].uniq!
    end
    return ret
  end

  def self.get_table(occurrences_by_species, dex)
    ret = []
    extra_form_hash = get_extra_form_hash
    for dex_index in 0...dex.size
      next if !occurrences_by_species.has_key?(dex[dex_index])
      ret.push(Row.new(
        dex[dex_index], occurrences_by_species[dex[dex_index]], dex_index+1
      ))
      ret.concat(get_form_rows(
        occurrences_by_species, extra_form_hash, dex[dex_index], dex_index+1
      ))
    end
    ret.sort!
    return ret
  end

  def self.get_form_rows(occurrences_by_species,extra_form_hash,species,index)
    ret = []
    return ret if !extra_form_hash.has_key?(species)
    for form_index in extra_form_hash[species]
      form_species = GameData::Species.get_species_form(species, form_index).id
      next if !occurrences_by_species.has_key?(form_species)
      ret.push(Row.new(form_species,occurrences_by_species[form_species],index))
    end
    return ret
  end

  # Get an extra form hash for quick access
  def self.get_extra_form_hash
    ret = {}
    for species in FORMS_TO_COUNT
      species_data = GameData::Species.get(species)
      ret[species_data.species] ||= []
      ret[species_data.species].push(species_data.form)
    end
    return ret
  end

  def self.remove_exception_species!(ocurrences_by_species)
    for species_exception in SPECIES_EXCEPTIONS
      next if !ocurrences_by_species.has_key?(species_exception)
      ocurrences_by_species.delete(species_exception)
    end
  end

  def self.merge_forms!(ocurrences_by_species)
    for species in ocurrences_by_species.keys
      species_data = GameData::Species.get(species)
      next if species_data.form == 0 || FORMS_TO_COUNT.include?(species)
      ocurrences_by_species[species_data.species] ||= 0
      ocurrences_by_species[species_data.species] += (
        ocurrences_by_species[species]
      )
      ocurrences_by_species.delete(species)
    end
  end
  
  def self.generate_txt(pokedex_name, content)
    ensure_file_path(file_full_name(pokedex_name))
    File.open(file_full_name(pokedex_name), "w"){|file| 
      file.write(
        "Created at "+Time.now.strftime("%Y-%m-%d %H:%M:%S")+"\n"+content
      )
    }
  end

  def self.file_full_name(pokedex_name)
    return sprintf(TXT_FILE_PATH+".txt",pokedex_name)
  end

  def self.ensure_file_path(file_path)
    split_path = file_path.split("/")
    split_path.pop
    return ensure_path(split_path.join("/"))
  end

  def self.ensure_path(path)
    current_path = ""
    for dir in path.split("/")
      current_path+=dir+"/"
      Dir.mkdir(current_path) unless File.exist?(current_path)
    end
  end
  
  # -1 means National Dex
  def self.get_dex_name(index)
    return Settings.pokedex_names[-1] if index==-1
    return Settings.pokedex_names.find{|d| d.is_a?(Array) && d[1]==index}[0]
  end
  
  # -1 means National Dex
  def self.get_dex_list(index)
    return pbLoadRegionalDexes[index] if index!=-1
    ret = []
    GameData::Species.each_species { |s| ret.push(s.id) }
    return ret
  end
  
  def self.get_all_valid_types
    ret = []
    GameData::Type.each do |type| 
      ret.push(type) if !type.pseudo_type && type.id != :SHADOW
    end
    return ret
  end
end

MenuHandlers.add(:debug_menu, :trainers_species_usage, {
  "name"        => _INTL("Print Trainers' Species Usage"),
  "parent"      => :other_menu,
  "description" => _INTL("Prints all pokémon usage by trainers."),
  "effect"      => proc {
    msgwindow = pbCreateMessageWindow
    if (
      safeExists?(TrainersSpeciesUsage.file_full_name(
        TrainersSpeciesUsage.get_dex_name(-1)
      )) && !pbConfirmMessageSerious(_INTL("File already exists. Overwrite?"))
    )
      pbDisposeMessageWindow(msgwindow)
      next
    end
    pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
    TrainersSpeciesUsage.generate_txt_for_every_dex
    pbMessageDisplay(msgwindow,
      _INTL("File generated in {1}.", TrainersSpeciesUsage::TXT_FILE_PATH)
    )
    pbDisposeMessageWindow(msgwindow)
  }
})