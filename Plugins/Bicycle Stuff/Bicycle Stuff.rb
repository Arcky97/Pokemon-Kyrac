class Game_Player < Game_Character
  alias :update_move_bike :update_move
  def update_move
      update_move_bike
      if $PokemonGlobal&.bicycle && ($game_map && GameData::MapMetadata.get($game_map.map_id)&.has_flag?("ForceBikeDown")) && $game_switches[81]
        case Input.dir4
        when 0, 2
          if passable?(@x, @y, 2) && !@move_route_forcing
            move_down unless moving? || @move_route_forcing || $game_temp.message_window_showing
          end
        end
      end
  end

  def set_movement_type(type)
    meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
    new_charset = nil
    case type
    when :fishing
      new_charset = pbGetPlayerCharset(meta.fish_charset)
    when :surf_fishing
      new_charset = pbGetPlayerCharset(meta.surf_fish_charset)
    when :diving, :diving_fast, :diving_jumping, :diving_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.dive_charset)
    when :surfing, :surfing_fast, :surfing_jumping, :surfing_stopped
      if !@move_route_forcing
        self.move_speed = (type == :surfing_jumping) ? 3 : 4
      end
      new_charset = pbGetPlayerCharset(meta.surf_charset)
    when :cycling, :cycling_fast, :cycling_jumping, :cycling_stopped
      if !@move_route_forcing
        if ($game_map && GameData::MapMetadata.get($game_map.map_id)&.has_flag?("ForceBikeDown")) && $game_switches[81]
          case @direction
          when 4,6,8
            self.move_speed = 3
          else
            self.move_speed = 5
          end
        else
          self.move_speed = (type == :cycling_jumping) ? 3 : 5
        end
      end
      new_charset = pbGetPlayerCharset(meta.cycle_charset)
    when :running
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.run_charset)
    when :ice_sliding
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    else   # :walking, :jumping, :walking_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    end
    @character_name = new_charset if new_charset
  end
end