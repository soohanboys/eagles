class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :is_admin?, only: [:new, :edit, :update, :destroy]
  before_action :set_league_and_ground, only: [:index, :new, :edit]

  # GET /games
  # GET /games.json
  def index
    @games_by_year = (params[:year]) ? Game.by_year(params[:year]) : Game.all
    @games = (params[:league_id]) ? @games_by_year.where(league_id: params[:league_id]) : @games_by_year
    @games = @games.sort_by { |game| game.game_start_time }
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @score_boxes = @game.score_box.split "\t"
    @at_bat_batter_record = AtBatBatterRecord.batting_result_codes_of_games(@game.id)
    @player_positions = AtBatBatterRecord.player_position(@game.id)
    @game_batter_record = GameBatterRecord.where(game_id: @game.id)
    @game_pitcher_records = GamePitcherRecord.pitcher_results_of_game(@game.id)
    @game_pitcher_record_columns = GamePitcherRecord.column_names

    @current_players = []
    @player_game_batter_records = {}
    @player_game_field_simple_records = {}
    for @batting_order in 0..25
      @current_players[@batting_order] = @game.player_of_at_bat(@batting_order)
      next if @current_players[@batting_order].empty?
      @current_players[@batting_order].each do |current_player|
        @player_game_batter_records[current_player.id] = @game_batter_record.where(player: current_player).first
        @player_game_field_simple_records[current_player.id] = current_player.game_field_simple_record_of(@game.id)
      end
    end
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
    @score_boxes = @game.score_box.split "\t"
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new_game_record(params, game_params)
    if @game
      redirect_to new_game_detail_record_path(game_id: @game.id), notice: 'Game was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    if @game.update_game_record(params, game_params)
      redirect_to @game
    else
      format.html { render :edit }
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    ActiveRecord::Base.transaction do
      unless GamePitcherRecord.destroy_game_record(@game.id) and
        AtBatBatterRecord.destroy_game_record(@game.id) and
        GameBatterRecord.destroy_game_record(@game.id)
        format.html { render :new }
      end
    end

    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:home_team, :away_team, :home_score, :away_score, :stadium, :game_start_time, :game_type, :score_box, :league_id, :ground_id)
    end

    def is_admin?
      @current_user ||= User.find_by(id: session[:user_id])
      redirect_to root_path, notice: 'Login required.' unless @current_user

      true
    end

    def set_league_and_ground
      @leagues = League.all
      @grounds = Ground.all
    end
end
