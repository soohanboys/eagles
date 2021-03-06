class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy, :show_batting, :show_pitching]
  before_action :set_records, only: [:index, :show]
  before_action :is_admin?, only: [:index_admin, :new, :edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
  end

  def index_admin
    @players = Player.all
  end

  def index_batting
    set_batter_records
  end

  def index_pitching
    set_pitcher_records
  end

  def index_fielding
    set_field_records
  end

  def update_total_records
    @success = true
    ActiveRecord::Base.transaction do
      TotalBatterRecord.destroy_all
      TotalPitcherRecord.destroy_all
      unless TotalBatterRecord.summarize and TotalPitcherRecord.summarize
        @success = false
        raise ActiveRecord::Rollback
      end
      redirect_to root_path
    end

    redirect_to :back, notice: 'Something wrong during the update.' unless @success
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  def show_batting
    @at_bat_batter_records = AtBatBatterRecord.where(player_id: params[:id])
    @game_batter_records = GameBatterRecord.where(player_id: params[:id])
    @batter_records = { }
    @at_bat_batter_records.each do |at_bat_batter_record|
      unless @batter_records[at_bat_batter_record.game_id]
        @new_at_batter_record_hash = { at_bat_batter_records: [ ] }
        @batter_records[at_bat_batter_record.game_id] = @new_at_batter_record_hash
        @batter_records[at_bat_batter_record.game_id][:at_bat_batter_records].push at_bat_batter_record
      else
        @batter_records[at_bat_batter_record.game_id][:at_bat_batter_records].push at_bat_batter_record
      end
    end

    @game_batter_records.each do |game_batter_record|
      @batter_records[game_batter_record.game_id][:game_batter_records] =  game_batter_record if @batter_records[game_batter_record.game_id]
    end

    @game_ids = @at_bat_batter_records.pluck(:game_id).uniq
  end

  def show_pitching
    #@pitcher_record_columns = GamePitcherRecord.index_of_game_pitcher_records
    @pitcher_record_columns = GamePitcherRecord.column_names
    @game_pitcher_records = GamePitcherRecord.where(player_id: params[:id])
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def is_admin?
      @current_user ||= User.find_by(id: session[:user_id])
      redirect_to root_path, notice: 'Login required.' unless @current_user

      true
    end

    def set_player
      @player = Player.find(params[:id])
    end

    def set_records
      set_batter_records
      set_pitcher_records
      set_field_records
    end

    def set_batter_records
      @batter_record_columns = Settings.batter_record_displayed_column
      @batters = SeasonBatterRecord.batter_records(params)
    end

    def set_pitcher_records
      @pitcher_record_columns = Settings.pitcher_record_displayed_column
      @pitchers = SeasonPitcherRecord.pitcher_records(params)
    end

    def set_field_records
      @simple_field_records = GameFielderSimpleRecord.to_hash(params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name, :birth, :team, :back_number, :bats, :throws)
    end
end
