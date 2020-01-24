class MatchesController < ApplicationController
	require "json"
	require "rubygems"
	require "pp"
	load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_fetcher.rb'
	load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_logic.rb'
	
	
	@@api_logic = APILogic.new

	def index
		@matches = Match.all
	end
	
	def show
		@match = Match.select("*").joins([participant_dtos: :champion], :player_dtos).where("matches.id = ?", params[:id]).where("participant_dtos.participant_id = player_dtos.participant_dto_id").sort #[participant_dtos: :champion]
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
	private
		def match_params	
		params.require(:match).permit(:riot_game_id, :created_at, :updated_at, :season_id, :queue_id, :game_version, :platform_id, :game_mode, :map_id, :game_type, :game_duration, :game_creation)
		end

end
