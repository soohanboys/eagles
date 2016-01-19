module GameDetailRecordsHelper
  def index_of_game_pitcher_records
    [
      "game_id",
      "pitched_order",
      "player_id",
      "pitched_result",
      "hold",
      "innings_pitched",
      "plate_appearance",
      "at_bat",
      "hit",
      "homerun",
      "sacrifice_bunt",
      "sacrifice_fly",
      "run",
      "earned_run",
      "strike_out",
      "walk",
      "intentional_walk",
      "hit_by_pitch",
      "wild_pitch",
      "balk",
      "number_of_pitches",
    ]
  end

  def pitcher_name_result(game_pitcher_record, pitched_order, index)
    @pitcher = game_pitcher_record.where(pitched_order: pitched_order.to_s)
    if @pitcher.count > 0
      return Player.find(@pitcher.first[index.to_sym]).name
    end
    return " "
  end
end
