module ApplicationHelper
  def batting_player_name(at_bat_batter_record, batting_order)
    @player = at_bat_batter_record.where(batting_order: batting_order)
    if @player.count > 0
      Player.find(@player.first.player_id).name
    else
      return ""
    end
  end

  def player_id(at_bat_batter_record, batting_order)
    @player = at_bat_batter_record.where(batting_order: batting_order)
    if @player.count > 0
      @player.first.player_id
    else
      return nil
    end
  end

  def batting_player_position(at_bat_batter_record, batting_order)
    @player = at_bat_batter_record.where(batting_order: batting_order)
    if @player.count > 0
      @player.first.position
    else
      return ""
    end
  end

  def batting_result_code(at_bat_batter_record, batting_order, inning)
    @results = [ ]
    @inning_bat_records = at_bat_batter_record.where(batting_order: batting_order, inning: inning)
    if @inning_bat_records.present?
      @inning_bat_records.each do |at_bat_record|
        @results.push Settings.result_code[at_bat_record.result_code]
      end
    end
    return @results
  end

  def batting_player_game_record(at_bat_batter_record, game_batter_record, batting_order, feature)
    feature_symbol = feature.to_sym
    return "" unless at_bat_batter_record.where(batting_order: batting_order).first
    @player_id = at_bat_batter_record.where(batting_order: batting_order).first.player_id
    if game_batter_record.where(player_id: @player_id).first
      return game_batter_record.where(player_id: @player_id).first[feature_symbol]
    else
      return 0
    end
  end

  def pitcher_result_info(game_pitcher_record, pitched_order, index)
    @pitcher = game_pitcher_record.where(pitched_order: pitched_order.to_s)
    if @pitcher.count > 0
      if index == "pitched_result"
        return "W" if @pitcher.first[:win]
        return "L" if @pitcher.first[:lose]
        return "SV" if @pitcher.first[:save_point]
        return " "
      end
      return @pitcher.first[index.to_sym]
    end
    return " "
  end
end
