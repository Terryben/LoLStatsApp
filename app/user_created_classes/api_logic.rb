class APILogic
	require "rubygems"
	require "pp"
	require "json"
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_fetcher.rb'
	
	#genertic api fetcher for all methods to use

	def running_thread_count #borrowed from used Kashyap on Stack Overflow
		Thread.list.select {|thread| thread.status == "run"}.count
	end
	def matchlist_from_api(match_id, api_key) #load matchlist from api but with params from a post. Could probably do dynamic method parameters and combine with load match from api 
		#spawn a concurrent tast that loads the matches while the user can still move about the site
		i = 0
		j = 0
		isMatchListRunning = false
		Thread.list.select {|thread|
			if thread[:name] == "TheGetMatchListThread" && thread.alive? then
				isMatchListRunning = true
			end
		}
		puts "The running thread count is #{get_running_thread_count}"
		if !isMatchListRunning then
			puts "Beginning new thread."
			child_pid = Thread.new{
				Thread.current[:name] = "TheGetMatchListThread"
				matchlist_from_api_params(params[:match_id], params[:api_key])
			}
			return true	
		else
			return false
		end
	end	

	def rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
		#array for player ranks in match to find match average
		rankHash = Hash.new
		#analyzing a match means you have pulled the match list for the ten players in that match.
		#array for the summoners in a specific match. Load all summoners in the database
		summoners_in_match.each do |sum|
			sum_rank = sum_instance.load_summoner_from_api(sum, api_key)
			#load the rank value into the hash set, or increment the count value if it already exists. 
			if rankHash.key?(sum_rank)
				rankHash[sum_rank] += 1
			else
				rankHash[sum_rank] = 1
			end
			sleep(2)
		end

		#loop through and find highest count and use that value as the rank of the match
		highestRank = ""
		rankCount = 0
		rankHash.each do |rank, count|
			puts "The rank is: #{rank}"
			puts count
			if count > rankCount
				highestRank = rank
				rankCount = count
			end
		end
		puts "The highest rank is: #{highestRank}"
		puts "RankCount is: #{rankCount}"
		return [highestRank, rankCount]
	end

	def matchlist_from_api_params(match_id, api_key)
		main_match = Match.find_by(riot_game_id: match_id)
		#puts "Main match is #{main_match}"
		#puts "Analyzed is #{main_match.analyzed.nil?}"
		puts main_match.nil?
		if !main_match.nil? && main_match.analyzed == false then
			sum_instance = SummonersController.new
			champ_instance = ChampionController.new
			summoners_in_match = PlayerDto.select("summoner_name").joins(:match).where("matches.riot_game_id = #{match_id}")
			rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
			jsonMatchListArray = Array.new
			i = 0
			#now get the account id and matchlist for each summoner. Pulling the summoner account id from the JSON above would be faster than querying the database
			summoners_in_match.each do |sum|
				puts "Here 2"
				puts "Name is #{sum.summoner_name}"
				if Summoner.exists?(name: sum.summoner_name) then
					accId = sum_instance.get_account_id(sum.summoner_name)
					puts accId
					uri = "https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/#{accId}?api_key=#{api_key}"
					jsonMatchListArray[i] = APIFetcher.get_api_request_as_json(uri)
					i = i + 1
					sleep(2)
				end
			end
		
			i = 0
			#loop through the match lists in the array. Loop through the matches in the match list and add them to the database
			jsonMatchListArray.each do |matchList|
				puts "Here 3"
				puts matchList
				if matchList.head == "200" && !matchList.tail.nil? then
					ml = matchList.tail
					puts "ML IS"
					puts ml
					ml["matches"].each do |match|
						id = api_fetch.is_nil_ret_int(match.dig("gameId"))
						if !(id	== "-1")
							load_match_from_api(id, api_key)
							sleep(2)
							summoners_in_match = PlayerDto.select("summoner_name").joins(:match).where("matches.riot_game_id = #{id}")
							rank_of_match(sum_instance, id, api_key, summoners_in_match)
						end
					end
				end
			end
			main_match.analyzed = true
			main_match.save
			return true
		else
			return false
		end
	end


	def api_load_match_from_api(match_id, api_key) #Read and save the data from a match by match ID
		#uri = "https://na1.api.riotgames.com/lol/match/v4/matches/#{matchId}?api_key=#{params[:api_key]}"
		uri = "https://na1.api.riotgames.com/lol/match/v4/matches/#{match_id}?api_key=#{api_key}"
		puts "Can I read this101010?"
		api_fetch = APIFetcher.new
		#puts @api_fetch.nil?
		puts "What about this?"

		parsed_match_input = api_fetch.get_api_request_as_json(uri)
		if parsed_match_input.head == "429" then
			return [429, "API Timeout. Stop making calls for a while."]
		end
		if parsed_match_input.head == "200" && !parsed_match_input.tail.nil? && !Match.exists?(riot_game_id: match_id) then
	
			#jm = json_match
			jm = parsed_match_input.tail
                        #parsed_input["matches"].each do |jm| #jm = json match
			#	Save the match
			summoners_in_match = Array.new
			#create an array to hold the 10 champion positional stats structs we will use later. CPS requires info from many different tables. Better to collect it all here, than pull it out of the data base later
			cps_array = Array.new
			#puts jm
			cps_struct = Struct.new(:champion_id, :team_id, :ladder_rank_of_match, :game_version, :lane, :participant_dto_id, :team_stats_dto_id, :win, :match_id)
			for k in 0..9 do
				cps_array[k] = cps_struct.new(-1, -1, -1, "none", "none", -1, -1, "null", -1) 
				
			end
			#need another array for the banned champions. We will add to a champions ban rate after we know the ladder rank of the match
			ban_array = Array.new
			ban_array_struct = Struct.new(:champion_id, :match_id)
			for j in 0..9
				ban_array[j] = ban_array_struct.new(-1, -1)
			end
			#pass the json match to create a match method. It will pull out the match parameters, Save the match, then return the match
			@match = create_a_match(jm)
			
				puts "The match id is: #{@match.id}"
			#	Save the team stats dto
				j = 0		
				jm["teams"].each do |team|
					#create a team stats dto and then save it
					@team_stats_dto = create_a_team_stats_dto(team)
					k = 0
					#add in the team stats to the first half of the champions
					until k == 5 do
						cps_array[k + j]["match_id"] = @match.id
						cps_array[k + j].team_id = @team_stats_dto.team_id
						cps_array[k + j].win = @team_stats_dto.win
						cps_array[k + j].game_version = @match.game_version
						cps_array[k + j].team_stats_dto_id = @team_stats_dto.id
						k = k + 1
					end
					#team bans
					k = 0
					team["bans"].each do |ban|
						#pass the ban to the create a team bans method. Returns a saved team bans dto
						@team_bans_dto = create_a_team_bans_dto(ban)
						#get the banned champs
						ban_array[k + j].champion_id = @team_bans_dto.champion_id
						ban_array[k + j].match_id = @match.id
						k = k + 1
					end
					j = 5
				end
				k = 0
			#	Save player dto which is inside participant identities	
				jm["participantIdentities"].each do |pi|
						#create a player dto object and save it using the json data
						@player_dto = create_a_player_dto(pi)
						#get the summoners in the match so we can get the rank of the match later, without looping again
						summoners_in_match[k] =  api_fetch.is_nil_ret_char(pi.dig("player", "summonerName"))
						k = k + 1
				end
				k = 0
				#need all the participant dtos before we can calculate win percentage. stuffing them in an array is faster than recalling them from the database. Same with the participant timelines
				#participant timeline dto array
				pt_array = Array.new
				#participant dto array
				pd_array = Array.new
				jm["participants"].each do |parti|

					#create a participant dto object and save it using the participants json data
					@participant_dto = create_a_participant_dto(parti)
					#save it in an array as well to be used later. Faster than loading from DB
					pd_array[k] = @participant_dto
					#create a participant stats dto object with the json particiants info and save it
					@participant_stats_dto = create_a_participant_stats_dto(parti)
					#create a participant timeline dto object with the json particiants info and save it
					@participant_timeline_dto = create_a_participant_timeline_dto(parti)
					
					pt_array[k] = @participant_timeline_dto

					
					#=end
					k = k + 1
				end
				#cps_array[k] = Struct.new(:champion_id, :match_id, :team_id, :ladder_rank_of_match, :game_version, :role, :participant_dto_id, :team_stats_dto_id, :win, :match_id)
				#loop through the participant dto array and assign the values to a cps struct in the cps struct array
				pd_array.each do |pd|
					puts "The team id is #{pd.team_id} and champ id is: #{pd.champion_id}"
					k = 0
					while k < 10
						#puts "This is the PD.champion ids:"
						#puts pd.champion_id
						#puts "cps team ID"
						#puts cps_array[k].team_id
						#puts "pd.teamid"
						#puts pd.team_id
						if cps_array[k].team_id == pd.team_id && cps_array[k].champion_id == -1 then
							cps_array[k].champion_id = pd.champion_id
							cps_array[k].participant_dto_id = pd.participant_id
							k = 10
						end
						k = k + 1
					end
				end
				pt_array.each do |pt|
					puts "the timeline role is: #{pt.lane}"
					k = 0
					while k < 10
						if pt.participant_dto_id == cps_array[k].participant_dto_id then
							cps_array[k].lane = pt.lane
							k = 10
						end
						k = k + 1
					end
				end
				#after this, create the champ pos stats object.
				rank_of_match_var = rank_of_match(SummonersController.new, match_id, api_key, summoners_in_match)
				@match.ladder_rank_of_match = rank_of_match_var[0]
				@match.save
				matches_won = 0
				matches_lost = 0
				g_version = cps_array[0].game_version[0..3]
				cps_array.each do |cps|
					puts "The win is #{cps.win}"
					if cps.win.casecmp("win") == 0 || cps.win.casecmp("true") == 0 then
						matches_won = 1
						matches_lost = 0
						puts "AM I HERE WHEN I SHOULDNT BE???"
					else
						matches_won = 0
						matches_lost = 1
					end
					@cps_from_db = ChampionPositionalStat.find_by(champion_id:  cps.champion_id, cps_ladder_rank: rank_of_match_var[0], cps_position: cps.lane, game_version: g_version)
					if @cps_from_db.nil? then
						@cps_from_db = ChampionPositionalStat.new(pickrate: 1, banrate: 0, num_of_matches_won: matches_won, num_of_matches_lost: matches_lost, \
											  game_version: g_version, cps_ladder_rank: rank_of_match_var[0], \
											   cps_position: cps.lane, champion_id: cps.champion_id)
						@cps_from_db.save
					else
						@cps_from_db.pickrate = @cps_from_db.pickrate + 1
						@cps_from_db.num_of_matches_won = @cps_from_db.num_of_matches_won + matches_won				
						@cps_from_db.num_of_matches_lost = @cps_from_db.num_of_matches_lost + matches_lost
						@cps_from_db.save
					end
				end
				puts "Num of elements in ban array is: #{ban_array.count}"
				ban_array.each do |ba|
					@cps_from_db = ChampionPositionalStat.find_by(champion_id: ba.champion_id, cps_ladder_rank: rank_of_match_var[0])
					if @cps_from_db.nil? && ba.champion_id != -1
						@cps_from_db = ChampionPositionalStat.new(pickrate: 0, banrate: 1, num_of_matches_won: 0, num_of_matches_lost: 0, \
											  game_version: g_version, cps_ladder_rank: rank_of_match_var[0], \
											  cps_position: 0, champion_id: ba.champion_id)
						@cps_from_db.save
					elsif ba.champion_id != -1
						@cps_from_db.banrate = @cps_from_db.banrate + 1
						@cps_from_db.game_version = g_version
						@cps_from_db.save
					end

				end				
			end
					
		return[200, "Match successfully loaded into database."]
    end
	#uses api_fetcher in services to pull needed info from Riot's api to create a summoner in the database. Parses data from two separate API calls then queries to see if the summoner already
	# exists in the database. If not, it creates it. If it does exist, it updates the summoner with the new up to date data.
	# also returns the summoners rank
	def api_load_summoner_from_api(summoner_name, api_key)
		r_uri = "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key}"
		api_fetch = APIFetcher.new
		parsed_summoner_input = api_fetch.get_api_request_as_json(r_uri)
		ret_val = ""	
		if parsed_summoner_input.head = 200 && !parsed_summoner_input.tail.nil? then
			puts "Id is: "
			puts parsed_summoner_input.tail.dig("id")

			parsed_league_input = api_fetch.get_api_request_as_json("https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/#{parsed_summoner_input.tail.dig("id")}?api_key=#{api_key}")
		
			if parsed_league_input.head = 200 && !parsed_league_input.tail[0].nil? then
				
				puts "In the creation"
				puts parsed_summoner_input
				puts parsed_league_input

				ret_val = parsed_league_input.tail[0].dig("tier")
				Summoner.find_or_initialize_by(name: parsed_summoner_input.tail["name"]).update(puuid: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("puuid")), \
										  level: api_fetch.is_nil_ret_int(parsed_summoner_input.tail.dig("summonerLevel")), \
										  account_id: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("accountId")), \
										  league_id: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("id")), \
										  queue_type: api_fetch.is_nil_ret_char(parsed_league_input.tail[0].dig("queueType")), \
										  rank: api_fetch.is_nil_ret_char(parsed_league_input.tail[0].dig("rank")), \
										  tier: api_fetch.is_nil_ret_char(parsed_league_input.tail[0].dig("tier")))
			else

				puts "In the other spot"
				puts parsed_summoner_input
				Summoner.find_or_initialize_by(name: parsed_summoner_input.tail["name"]).update(puuid: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("puuid")), \
										  level: api_fetch.is_nil_ret_int(parsed_summoner_input.tail.dig("summonerLevel")), \
										  account_id: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("accountId")), \
										  league_id: api_fetch.is_nil_ret_char(parsed_summoner_input.tail.dig("id")))
			end
		else
			return "ERROR: Response from API was nil and/or code was not 200."
		end
		return ret_val
	end
	#get a JSON match object, pull out the match parameters, save the match in the DB, then return the match
	def create_a_match(jm) #jm stands for json match
		api_fetch = APIFetcher.new
		temp_match = Match.new(riot_game_id: api_fetch.is_nil_ret_int(jm.dig("gameId")), \
					 created_at: jm["gameCreation"], \
					 updated_at: Time.now, \
					 season_id: api_fetch.is_nil_ret_int(jm.dig("seasonId")), \
					 queue_id: api_fetch.is_nil_ret_int(jm.dig("queueId")), \
					 game_version: api_fetch.is_nil_ret_char(jm.dig("gameVersion")), \
					 platform_id: api_fetch.is_nil_ret_char(jm.dig("platformId")), \
					 game_mode: api_fetch.is_nil_ret_char(jm.dig("gameMode")), \
					 map_id: api_fetch.is_nil_ret_int(jm.dig("mapId")), \
					 game_type: api_fetch.is_nil_ret_char(jm.dig("gameType")), \
					 game_duration: api_fetch.is_nil_ret_int(jm.dig("gameDuration")), \
					 game_creation: api_fetch.is_nil_ret_int(jm.dig("gameCreation")), \
					 analyzed: false)
					 temp_match.save
		return temp_match
	end
	#passed a team json object method creates a team_stats_dto object and saves it
	def create_a_team_stats_dto(team)
		api_fetch = APIFetcher.new
		temp_tsd = TeamStatsDto.new(team_id: api_fetch.is_nil_ret_int(team.dig("teamId")), \
									first_dragon: api_fetch.is_nil_ret_bool(team.dig("firstDragon")), \
									first_inhibitor: api_fetch.is_nil_ret_bool(team.dig("firstInhibitor")), \
									baron_kills: api_fetch.is_nil_ret_int(team.dig("baronKills")), \
									first_rift_herald: api_fetch.is_nil_ret_bool(team.dig("firstRiftHerald")), \
									first_baron: api_fetch.is_nil_ret_bool(team.dig("firstBaron")), \
									rift_herald_kills: api_fetch.is_nil_ret_int(team.dig("riftHeraldKills")), \
									first_blood: api_fetch.is_nil_ret_bool(team.dig("firstBlood")), \
									first_tower: api_fetch.is_nil_ret_bool(team.dig("firstTower")), \
									vilemaw_kills: api_fetch.is_nil_ret_int(team.dig("vilemawKills")), \
									inhibitor_kills: api_fetch.is_nil_ret_int(team.dig("inhibitorKills")), \
									tower_kills: api_fetch.is_nil_ret_int(team.dig("tower_kills")), \
									dominion_victory_score: api_fetch.is_nil_ret_int(team.dig("dominionVictoryScore")), \
									win: api_fetch.is_nil_ret_char(team.dig("win")), \
									dragon_kills: api_fetch.is_nil_ret_bool(team.dig("dragonKills")), \
									match_id: @match.id)
		temp_tsd.save!
		return temp_tsd
	end
	#passed a ban json object method creates a team_bans_dto object and saves it
	def create_a_team_bans_dto(ban)
		api_fetch = APIFetcher.new
		temp_tbd = TeamBansDto.new(pick_turn: api_fetch.is_nil_ret_int(ban.dig("pickTurn")), \
						champion_id: api_fetch.is_nil_ret_int(ban.dig("championId")), \
						team_stats_dto_id: @team_stats_dto.id)
		temp_tbd.save
		return temp_tbd
	end
	#passed a participants json object method creates a player dto object and saves it
	def create_a_player_dto(pi)
		api_fetch = APIFetcher.new
		temp_pd = PlayerDto.new(platform_id: api_fetch.is_nil_ret_char(pi.dig("player", "platformId")), \
									current_account_id: api_fetch.is_nil_ret_char(pi.dig("player", "currentAccountId")), \
									summoner_name: api_fetch.is_nil_ret_char(pi.dig("player", "summonerName")), \
									summoner_id: api_fetch.is_nil_ret_int(pi.dig("player", "summonerId")), \
									current_platform_id: api_fetch.is_nil_ret_char(pi.dig("player", "currentPlatformId")), \
									account_id: api_fetch.is_nil_ret_int(pi.dig("player", "accountId")), \
									match_history_uri: api_fetch.is_nil_ret_char(pi.dig("player", "matchHistoryUri")), \
									profile_icon: api_fetch.is_nil_ret_int(pi.dig("player", "profileIcon")), \
									match_id: @match.id, \
									participant_dto_id: api_fetch.is_nil_ret_int(pi.dig("participantId")))    
		temp_pd.save!
		return temp_pd
	end
	#passed a participant dto json object method creates a participant dto object and saves it
	def create_a_participant_dto(parti)
		api_fetch = APIFetcher.new
		temp_pd = ParticipantDto.new(participant_id: api_fetch.is_nil_ret_int(parti.dig("participantId")), \
									team_id: api_fetch.is_nil_ret_int(parti.dig("teamId")), \
									match_id: @match.id, \
									champion_id: api_fetch.is_nil_ret_int(parti.dig("championId")), \
									spell_1_id: api_fetch.is_nil_ret_int(parti.dig("spell1Id")), \
									spell_2_id: api_fetch.is_nil_ret_int(parti.dig("spell2Id")), \
									highest_achieved_season_tier: api_fetch.is_nil_ret_char(parti.dig("highestAchievedSeasonTier")))										
		temp_pd.save!
		return temp_pd
	end
	#passed a participant dto json object method creates a participant stats dto object and saves it
	def create_a_participant_stats_dto(parti)
		api_fetch = APIFetcher.new
		temp_psd = ParticipantStatsDto.new(first_blood_assist: api_fetch.is_nil_ret_bool(parti.dig("stats", "firstBloodAssist")), \
											vision_score: api_fetch.is_nil_ret_int(parti.dig("stats", "visionScore")), \
											magic_damage_dealt_to_champions: api_fetch.is_nil_ret_int(parti.dig("stats", "magicDamageDealtToChampions")), \
											damage_dealt_to_objectives: api_fetch.is_nil_ret_int(parti.dig("stats", "damageDealtToObjectives")), \
											total_time_crowd_control_dealt: api_fetch.is_nil_ret_int(parti.dig("stats", "totalTimeCrowdControlDealt")), \
											longest_time_spent_living: api_fetch.is_nil_ret_int(parti.dig("stats", "longestTimeSpentLiving")), \
											triple_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "tripleKills")), \
											node_neutralize_assist: api_fetch.is_nil_ret_int(parti.dig("stats", "nodeNeutralizeAssist")), \
											perk_1_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk1Var1")), \
											perk_1_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk1Var3")), \
											perk_1_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk1Var2")), \
											perk_3_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk3Var3")), \
											perk_3_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk3Var2")), \
											player_score_9: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore9")), \
											player_score_8: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore8")), \
											kills: api_fetch.is_nil_ret_int(parti.dig("stats", "kills")), \
											player_score_1: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore1")), \
											player_score_0: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore0")), \
											player_score_3: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore3")), \
											player_score_2: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore2")), \
											player_score_5: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore5")), \
											player_score_4: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore4")), \
											player_score_6: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore7")), \
											player_score_7: api_fetch.is_nil_ret_int(parti.dig("stats", "playerScore7")), \
											perk_5_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk5Var1")), \
											perk_5_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk5Var3")), \
											perk_5_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk5Var2")), \
											total_score_rank: api_fetch.is_nil_ret_int(parti.dig("stats", "totalScoreRank")), \
											neutral_minions_killed: api_fetch.is_nil_ret_int(parti.dig("stats", "neutralMinionsKilled")), \
											damage_dealt_to_turrets: api_fetch.is_nil_ret_int(parti.dig("stats", "damageDealtToTurrets")), \
											physical_damage_dealt_to_champions: api_fetch.is_nil_ret_int(parti.dig("stats", "physicalDamageDealtToChampions")), \
											node_capture: api_fetch.is_nil_ret_int(parti.dig("stats", "nodeCapture")), \
											largest_multikill: api_fetch.is_nil_ret_int(parti.dig("stats", "largestMultiKill")), \
											perk_2_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk2Var2")), \
											perk_2_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk2Var3")), \
											total_units_healed: api_fetch.is_nil_ret_int(parti.dig("stats", "totalUnitsHealed")), \
											perk_2_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk2Var1")), \
											perk_4_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk4Var1")), \
											perk_4_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk4Var2")), \
											perk_4_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk4Var3")), \
											wards_killed: api_fetch.is_nil_ret_int(parti.dig("stats", "wardsKilled")), \
											largest_critical_strike: api_fetch.is_nil_ret_int(parti.dig("stats", "largestCriticalStrike")), \
											largest_killing_spree: api_fetch.is_nil_ret_int(parti.dig("stats", "largestKillingSpree")), \
											quadra_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "quadraKills")), \
											team_objective: api_fetch.is_nil_ret_int(parti.dig("stats", "teamObjective")), \
											magic_damage_dealt: api_fetch.is_nil_ret_int(parti.dig("stats", "magicDamageDealt")), \
											item_2: api_fetch.is_nil_ret_int(parti.dig("stats", "item2")), \
											item_3: api_fetch.is_nil_ret_int(parti.dig("stats", "item3")), \
											item_0: api_fetch.is_nil_ret_int(parti.dig("stats", "item0")), \
											item_6: api_fetch.is_nil_ret_int(parti.dig("stats", "item6")), \
											item_5: api_fetch.is_nil_ret_int(parti.dig("stats", "item5")), \
											item_1: api_fetch.is_nil_ret_int(parti.dig("stats", "item1")), \
											item_4: api_fetch.is_nil_ret_int(parti.dig("stats", "item4")), \
											neutral_minions_killed_team_jungle: api_fetch.is_nil_ret_int(parti.dig("stats", "neutralMinionsKilledTeamJungle")), \
											perk_0: api_fetch.is_nil_ret_int(parti.dig("stats", "perk0")), \
											perk_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk1")), \
											perk_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk2")), \
											perk_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk3")), \
											perk_4: api_fetch.is_nil_ret_int(parti.dig("stats", "perk4")), \
											perk_5: api_fetch.is_nil_ret_int(parti.dig("stats", "perk5")), \
											perk_3_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk3Var1")), \
											damage_self_mitigated: api_fetch.is_nil_ret_int(parti.dig("stats", "damageSelfMitigated")), \
											magical_damage_taken: api_fetch.is_nil_ret_int(parti.dig("stats", "magicalDamageTaken")), \
											first_inhibitor_kill: api_fetch.is_nil_ret_bool(parti.dig("stats", "firstInhibitorKill")), \
											true_damage_taken: api_fetch.is_nil_ret_int(parti.dig("stats", "trueDamageTaken")), \
											node_neutralize: api_fetch.is_nil_ret_int(parti.dig("stats", "nodeNeutralize")), \
											assists: api_fetch.is_nil_ret_int(parti.dig("stats", "assists")), \
											combat_player_score: api_fetch.is_nil_ret_int(parti.dig("stats", "combatPlayerScore")), \
											perk_primary_style: api_fetch.is_nil_ret_int(parti.dig("stats", "perkPrimaryStyle")), \
											gold_spent: api_fetch.is_nil_ret_int(parti.dig("stats", "goldSpent")), \
											true_damage_dealt: api_fetch.is_nil_ret_int(parti.dig("stats", "trueDamageDealt")), \
											participant_id: api_fetch.is_nil_ret_int(parti.dig("stats", "participantId")), \
											total_damage_taken: api_fetch.is_nil_ret_int(parti.dig("stats", "totalDamageTaken")), \
											physical_damage_dealt: api_fetch.is_nil_ret_int(parti.dig("stats", "physicalDamageDealt")), \
											sight_wards_bought_in_game: api_fetch.is_nil_ret_int(parti.dig("stats", "sightWardsBoughtInGame")), \
											total_damage_dealt_to_champions: api_fetch.is_nil_ret_int(parti.dig("stats", "totalDamageDealtToChampions")), \
											physical_damage_taken: api_fetch.is_nil_ret_int(parti.dig("stats", "physicalDamageTaken")), \
											total_player_score: api_fetch.is_nil_ret_int(parti.dig("stats", "totalPlayerScore")), \
											win: api_fetch.is_nil_ret_bool(parti.dig("stats", "win")), \
											objective_player_score: api_fetch.is_nil_ret_int(parti.dig("stats", "objectivePlayerScore")), \
											total_damage_dealt: api_fetch.is_nil_ret_int(parti.dig("stats", "totalDamageDealt")), \
											neutral_minions_killed_enemy_jungle: api_fetch.is_nil_ret_int(parti.dig("stats", "neutralMinionsKilledEnemyJungle")), \
											deaths: api_fetch.is_nil_ret_int(parti.dig("stats", "deaths")), \
											wards_placed: api_fetch.is_nil_ret_int(parti.dig("stats", "wardsPlaced")), \
											perk_sub_style: api_fetch.is_nil_ret_int(parti.dig("stats", "perkSubStyle")), \
											turret_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "turretKills")), \
											first_blood_kill: api_fetch.is_nil_ret_bool(parti.dig("stats", "firstBloodKill")), \
											true_damage_dealt_to_champions: api_fetch.is_nil_ret_int(parti.dig("stats", "trueDamageDealtToChampions")), \
											gold_earned: api_fetch.is_nil_ret_int(parti.dig("stats", "goldEarned")), \
											killing_sprees: api_fetch.is_nil_ret_int(parti.dig("stats", "killingSprees")), \
											unreal_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "unrealKills")), \
											altars_captured: api_fetch.is_nil_ret_int(parti.dig("stats", "altarsCaptured")), \
											first_tower_assist: api_fetch.is_nil_ret_bool(parti.dig("stats", "firstTowerAssist")), \
											champ_level: api_fetch.is_nil_ret_int(parti.dig("stats", "champLevel")), \
											first_tower_kill: api_fetch.is_nil_ret_bool(parti.dig("stats", "firstTowerKill")), \
											double_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "doubleKills")), \
											node_capture_assist: api_fetch.is_nil_ret_int(parti.dig("stats", "nodeCaptureAssist")), \
											inhibitor_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "inhibitorKills")), \
											perk_0_var_1: api_fetch.is_nil_ret_int(parti.dig("stats", "perk0Var1")), \
											perk_0_var_2: api_fetch.is_nil_ret_int(parti.dig("stats", "perk0Var2")), \
											perk_0_var_3: api_fetch.is_nil_ret_int(parti.dig("stats", "perk0Var3")), \
											vision_wards_bought_in_game: api_fetch.is_nil_ret_int(parti.dig("stats", "visionWardsBoughtInGame")), \
											altars_neutralized: api_fetch.is_nil_ret_int(parti.dig("stats", "altarsNeutralized")), \
											penta_kills: api_fetch.is_nil_ret_int(parti.dig("stats", "pentaKills")), \
											total_heal: api_fetch.is_nil_ret_int(parti.dig("stats", "totalHeal")), \
											time_ccing_others: api_fetch.is_nil_ret_int(parti.dig("stats", "timeCCingOthers")))
		temp_psd.save!
		return temp_psd
	end
	#passed a participant dto json object method creates a participant timeline dto object and saves it
	def create_a_participant_timeline_dto(parti)
		api_fetch = APIFetcher.new
		temp_ptd = ParticipantTimelineDto.new(lane: api_fetch.is_nil_ret_char(parti.dig("timeline", "lane")), \
											participant_dto_id: api_fetch.is_nil_ret_int(parti.dig("timeline", "participantId")), \
											role: api_fetch.is_nil_ret_char(parti["timeline"]["role"]), \
											creeps_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "0-10")), \
											creeps_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "10-20")), \
											creeps_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "20-30")), \
											creeps_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "30-end")), \
											xp_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "0-10")), \
											xp_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "10-20")), \
											xp_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "20-30")), \
											xp_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "30-end")), \
											gold_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "0-10")), \
											gold_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "10-20")), \
											gold_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "20-30")), \
											gold_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "30-end")), \
											damage_taken_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "0-10")), \
											damage_taken_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "10-20")), \
											damage_taken_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "20-30")), \
											damage_taken_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "30-end")), \
											damage_taken_diff_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "0-10")), \
											damage_taken_diff_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "10-20")), \
											damage_taken_diff_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "20-30")), \
											damage_taken_diff_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "30-end")), \
											cs_diff_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "0-10")), \
											cs_diff_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "10-20")), \
											cs_diff_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "20-30")), \
											cs_diff_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "30-end")), \
											xp_diff_pmd_0_10: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "0-10")), \
											xp_diff_pmd_10_20: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "10-20")), \
											xp_diff_pmd_20_30: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "20-30")), \
											xp_diff_pmd_30_end: api_fetch.is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "30-end")))
		temp_ptd.save!
		return temp_ptd
	end
end
