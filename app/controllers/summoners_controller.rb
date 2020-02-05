class SummonersController < ApplicationController

	require "json"
	require "rubygems"
	require "pp"
	require "ostruct"
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_fetcher.rb'
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_logic.rb'

	

	def index
		@summoners = Summoner.all
	end

	def show
		@summoner = Summoner.select("*")
	end

	def read_summoner_json
			load_summoner_from_api(params[:summoner_name], params[:api_key])
			redirect_to action: "index"
	end

	def get_account_id(sum)
		acc_id = Summoner.select("account_id").where("summoners.name = '#{sum}'")
		return acc_id.first.account_id
	end

	#uses api_fetcher in services to pull needed info from Riot's api to create a summoner in the database. Parses data from two separate API calls then queries to see if the summoner already
	# exists in the database. If not, it creates it. If it does exist, it updates the summoner with the new up to date data.
	# also returns the summoners rank
	def load_summoner_from_api(summoner_name, api_key)
		api_lgc = APILogic.new
		ret_val = api_lgc.api_load_summoner_from_api(summoner_name, api_key)
		if ret_val == "ERROR: Response from API was nil and/or code was not 200." then
			ret_val = ""
			puts "ERROR: Response from API was nil and/or code was not 200."
		end
		return ret_val

	end

	private
	#only allow the API key for the read summoner params. Will need when I create generic new or create methods
		#def api_params
		#	params.require(

end
