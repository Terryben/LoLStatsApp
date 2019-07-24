class SummonersController < ApplicationController

	require "json"
	require "rubygems"
	require "pp"
	require "ostruct"
	load "E:/Ruby/Ruby25-x64/LoL_Stats_App/app/services/api_fetcher.rb"

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

	#uses api_fetcher in services to pull needed info from Riot's api to create a summoner in the database. Parses data from two separate API calls then queries to see if the summoner already
	# exists in the database. If not, it creates it. If it does exist, it updates the summoner with the new up to date data.
	def load_summoner_from_api(summoner_name, api_key)
		r_uri = "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key}"
		parsed_summoner_input = get_api_request_as_json(r_uri)
		
		if parsed_summoner_input.head = 200 && !parsed_summoner_input.tail.nil? then

			parsed_league_input = get_api_request_as_json("https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/#{parsed_summoner_input.tail.dig("id")}?api_key=#{api_key}")
		
			if parsed_league_input.head = 200 && !parsed_league_input.tail[0].nil? then
				
				puts "In the creation"
				puts parsed_summoner_input
				puts parsed_league_input


				Summoner.find_or_initialize_by(name: parsed_summoner_input.tail["name"]).update(puuid: is_nil_ret_char(parsed_summoner_input.tail.dig("puuid")), \
										  level: is_nil_ret_int(parsed_summoner_input.tail.dig("summonerLevel")), \
										  account_id: is_nil_ret_char(parsed_summoner_input.tail.dig("accountId")), \
										  league_id: is_nil_ret_char(parsed_summoner_input.tail.dig("id")), \
										  queue_type: is_nil_ret_char(parsed_league_input.tail[0].dig("queueType")), \
										  rank: is_nil_ret_char(parsed_league_input.tail[0].dig("rank")), \
										  tier: is_nil_ret_char(parsed_league_input.tail[0].dig("tier")))
			else

				puts "In the other spot"
				puts parsed_summoner_input
				Summoner.find_or_initialize_by(name: parsed_summoner_input.tail["name"]).update(puuid: is_nil_ret_char(parsed_summoner_input.tail.dig("puuid")), \
										  level: is_nil_ret_int(parsed_summoner_input.tail.dig("summonerLevel")), \
										  account_id: is_nil_ret_char(parsed_summoner_input.tail.dig("accountId")), \
										  league_id: is_nil_ret_char(parsed_summoner_input.tail.dig("id")))
			end
		else
			puts "ERROR: Response from API was nil and/or code was not 200."
		end


	end

	private
	#only allow the API key for the read summoner params. Will need when I create generic new or create methods
		#def api_params
		#	params.require(

end
