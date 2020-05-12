class MatchesController < ApplicationController
	require "json"
	require "rubygems"
	require "pp"
	require "set"
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_fetcher.rb'
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_logic.rb'
	

	@@api_logic = APILogic.new
	Pp = Struct.new(:page_num, :record_count, :asc, :col_name)

	def index
		@matches = Match.select("*").where("id < 100")
		@page_params = Pp.new(1, Match.count, "", "")
	end
	
	def show
		@match = Match.select("*").joins([participant_dtos: :champion], :player_dtos).where("matches.id = ?", params[:id]).where("participant_dtos.participant_id = player_dtos.participant_dto_id").sort #[participant_dtos: :champion]
	end

	#Move to the next page on the index view. 100 records at a time
	def next_index_page
		#TO DO: ADD in parameters that you are sorted on. Ascending, decening, or rank of game/game mode
		@page_num = params[:page_num].to_i + 1
		@matches = Match.select("*").where("id < (#{@page_num} * 100)").where("id > ((#{@page_num} * 100)-100)")
		@record_count = Match.count
		render 'index'
		
	end

	def back_index_page
		#TO DO: ADD in parameters that you are sorted on. Ascending, decening, or rank of game/game mode
		@page_num = params[:page_num].to_i - 1
		if @page_num < 1 then
			@page_num = 1
		end
		@record_count = Match.count
		@matches = Match.select("*").where("id < (#{@page_num} * 100)").where("id > ((#{@page_num} * 100)-100)")
		render 'index'
	end
	
	#user passed the Riot game ID of the match, return it and only it to the user
	def search_for_match
		@matches = Match.select("*").where("riot_game_id = #{params[:match_id]}")
		@page_num = 1
		@record_count = Match.count
		render 'index'
	end
	
	#only do ascending and decending queries, and only on one field. Will not be able to sort by selected values on tables, and will not be able to do more than one ascending or decending query
	#if people want these I will have to pull custom reports for them
	def ascend_descend_next_back
		#params in order are :col_name, :page_num
		#have dictionary that matches param to column name
		#have param that is acending or decending
		#have param that is page number
		#build query that uses to variables, and returns first 100 values
		#@champion = Champion.select("*").left_outer_joins(:champion_positional_stats).where("champions.id = ?", params[:id])

		#Create a set with all the match columns in it. Then compare the user variables to the set. If we get a match then you can do the query on the returned set values
		#to prevent any malicious code from getting in
		match_col_set = Set["riot_game_id", "season_id", "queue_id", "game_version", "platform_id", "game_mode", "map_id", "game_type", "game_duration", "game_creation", "ladder_rank_of_match"]
		puts "The col name is #{params[:col_name]}"

		@page_params = Pp.new(params[:page_num].to_i, Match.count, params[:asc], params[:col_name])


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

	#button to select rank of game


	#button to sort by game mode
	def sort_by_game_rank
	end
	
	
	
	def new
	end

	def create
		@match = Match.new(match_params)
		@match.save
		redirect_to @match
	end
	def get_running_thread_count
		#@@api_logic = APILogic.new
		puts @@api_logic.running_thread_count
		@@api_logic.running_thread_count
	end
	def get_matchlist_from_api #load matchlist from api but with params from a post. Could probably do dynamic method parameters and combine with load match from api 
		#spawn a concurrent tast that loads the matches while the user can still move about the site
		if @@api_logic.matchlist_from_api(params[:match_id], params[:api_key]) then
			redirect_to action: "index"
		else
			flash[:error] = "Matchlist thread already running"
			redirect_to action: "index"
		end
	end	
	def get_rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
		#api logic finds us the average rank of a match, then we update the match with that rank
		highestRank, rankCount = @@api_logic.rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
		Match.where(:riot_game_id => match_id).update_all(:ladder_rank_of_match => highestRank)
	end
	
	def get_matchlist_from_api_params(match_id, api_key)
		if @@api_logic.matchlist_from_api_params(match_id, api_key) then
			flash[:success] = "Matchlist loaded into database."
		else
			flash[:error] = "Match not loaded in database."
		end
	end

	def read_json_file #load match from api but with params from a post. Could probably do dynamic method parameters and combine with load match from api 
		
		if params[:match_id] == ""
			flash[:error] = "Invalid input."
			redirect_to action: "index"	
		elsif Match.find_by(riot_game_id: params[:match_id]).nil?
			load_match_from_api(params[:match_id], params[:api_key])
			redirect_to action: "index"	
		else
			flash[:error] = "Match already loaded in database."
			redirect_to action: "index"	
		end
	end

	def load_match_from_api(match_id, api_key) #Read and save the data from a match by match ID
		error, text = @@api_logic.api_load_match_from_api(match_id, api_key)
		if error == 429 then
			flash[:error] = text
			return redirect_to 'http://localhost:3000'
		else
			flash[:success] = text
		end
	end

	#let the views access the page parameters
	def params_get
		@page_params
	end

	#need a helper to let view call this
	helper_method :params_get

	private
		def match_params	
		params.require(:match).permit(:riot_game_id, :created_at, :updated_at, :season_id, :queue_id, :game_version, :platform_id, :game_mode, :map_id, :game_type, :game_duration, :game_creation)
		end

end
