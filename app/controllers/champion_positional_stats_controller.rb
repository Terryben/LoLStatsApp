class ChampionPositionalStatsController < ApplicationController
  before_action :set_champion_positional_stat, only: [:show, :edit, :update, :destroy]


  Pp = Struct.new(:page_num, :record_count, :asc, :col_name, :num_matches, :position, :rank)
  # GET /champion_positional_stats
  # GET /champion_positional_stats.json
  def index
	  @champion_positional_stats = ChampionPositionalStat.select("*").joins(:champion).where("cps_position != 'NONE'").where("cps_position != '0'").where("cps_ladder_rank = 'PLATINUM'")
	  @page_params = Pp.new(1, ChampionPositionalStat.count, "asc", "id", Match.count, "", "PLATINUM")	
  end

  #filter sort
  def filter_sort

		#Create a set with all the match columns in it. Then compare the user variables to the set. If we get a match then you can do the query on the returned set values
		#to prevent any malicious code from getting in
		pos_set = Set["TOP", "JUNGLE", "MID", "BOTTOM", "SUPPORT"]
		rank_set = Set["IRON", "BRONZE", "SILVER", "GOLD", "PLATINUM", "DIAMOND", "MASTER", "GRANDMASTER", "CHALLENGER"]
		
		puts "The col name is #{params[:col_name]}"

		@page_params = Pp.new(params[:page_num].to_i, ChampionPositionalStat.count, params[:asc], params[:col_name])


		if !match_col_set.include?(@page_params.col_name) then 
			#puts "NOT EQUALS #{params[:col_name]}"
			flash[:error] = "Invalid column parameter chosen."
			redirect_to action: "index"	
		else
			#if the column name is the same as last time, swap the order of the table
			
			if @page_params.asc == "asc" then
				@asc = "asc"
			else
				@asc = "desc"
			end
			#set col name to the new column
			@temp_page_num = @page_params[:page_num].to_i
			@page_params[:record_count] = Match.count
			puts @asc.nil?
			puts "#{@asc}"
			puts "WHAT DOES THIS RETURN?"
			puts Arel.sql("#{params[:col_name]} #{@asc}")
			@matches = Match.select("*").order(Arel.sql("#{params[:col_name]} #{@asc}")).limit(100).offset((@temp_page_num * 100)-100)
			#USE RAW SQL

			render 'index'
		end
	end





  # GET /champion_positional_stats/1
  # GET /champion_positional_stats/1.json
  def show
  end

  # GET /champion_positional_stats/new
  def new
    @champion_positional_stat = ChampionPositionalStat.new
  end

  # GET /champion_positional_stats/1/edit
  def edit
  end

  # POST /champion_positional_stats
  # POST /champion_positional_stats.json
  def create
    @champion_positional_stat = ChampionPositionalStat.new(champion_positional_stat_params)

    respond_to do |format|
      if @champion_positional_stat.save
        format.html { redirect_to @champion_positional_stat, notice: 'Champion positional stat was successfully created.' }
        format.json { render :show, status: :created, location: @champion_positional_stat }
      else
        format.html { render :new }
        format.json { render json: @champion_positional_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /champion_positional_stats/1
  # PATCH/PUT /champion_positional_stats/1.json
  def update
    respond_to do |format|
      if @champion_positional_stat.update(champion_positional_stat_params)
        format.html { redirect_to @champion_positional_stat, notice: 'Champion positional stat was successfully updated.' }
        format.json { render :show, status: :ok, location: @champion_positional_stat }
      else
        format.html { render :edit }
        format.json { render json: @champion_positional_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /champion_positional_stats/1
  # DELETE /champion_positional_stats/1.json
  def destroy
    @champion_positional_stat.destroy
    respond_to do |format|
      format.html { redirect_to champion_positional_stats_url, notice: 'Champion positional stat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_champion_positional_stat
      @champion_positional_stat = ChampionPositionalStat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def champion_positional_stat_params
      params.fetch(:champion_positional_stat, {})
    end
end
