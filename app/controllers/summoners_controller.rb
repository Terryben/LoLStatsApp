class SummonersController < ApplicationController

	require "json"
	require "rubygems"
	require "pp"
	load "E:/Ruby/Ruby25-x64/LoL_Stats_App/app/services/api_fetcher.rb"

	def index
		@summoners = Summoner.all
	end

	def show
		@summoner = Summoner.select("*")
	end

	def read_summoner_json
		parsed_summoner_input = get_summoner_from_api("Chubbles")
		puts parsed_summoner_input

		parsed_league_input = get_league_from_api(parsed_summoner_input.dig("id"))

		puts parsed_league_input

		Summoner.find_or_initialize_by(name: parsed_summoner_input["name"]).update(puuid: is_nil_ret_char(parsed_summoner_input.dig("puuid")), \
										  level: is_nil_ret_int(parsed_summoner_input.dig("summonerLevel")), \
										  account_id: is_nil_ret_char(parsed_summoner_input.dig("accountId")), \
										  league_id: is_nil_ret_char(parsed_summoner_input.dig("id")), \
										  queue_type: is_nil_ret_char(parsed_league_input.dig("queueType")), \
										  rank: is_nil_ret_char(parsed_league_input.dig("rank")), \
										  tier: is_nil_ret_char(parsed_league_input.dig("tier")))
	end


end
