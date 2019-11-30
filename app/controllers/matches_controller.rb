class MatchesController < ApplicationController
	require "json"
	require "rubygems"
	require "pp"
	load "E:/Ruby/Ruby25-x64/LoL_Stats_App/app/services/api_fetcher.rb"
	
	def index
		@matches = Match.all
	end
	
	def show
		@match = Match.select("*").joins([participant_dtos: :champion], :player_dtos).where("matches.id = #{params[:id]}").where("participant_dtos.participant_id = player_dtos.participant_dto_id").sort #[participant_dtos: :champion]
	end
	
	
	def new
	end

	def create
		@match = Match.new(match_params)
		@match.save
		redirect_to @match
	end
	def get_running_thread_count #borrowed from used Kashyap on Stack Overflow
		Thread.list.select {|thread| thread.status == "run"}.count
	end
	def get_matchlist_from_api #load matchlist from api but with params from a post. Could probably do dynamic method parameters and combine with load match from api 
		#spawn a concurrent tast that loads the matches while the user can still move about the site
		i = 0
		j = 0
		#f = File.open('logfile.txt', 'w')
		#f.write("The running thread count is #{get_running_thread_count}")
		#f.close
		isMatchListRunning = false
		Thread.list.select {|thread|
			if thread[:name] == "TheGetMatchListThread" && thread.alive? then
				isMatchListRunning = true
			end
		}
		puts "The running thread count is #{get_running_thread_count}"
		if !isMatchListRunning then
			child_pid = Thread.new{
				Thread.current[:name] = "TheGetMatchListThread"
				get_matchlist_from_api_params(params[:match_id], params[:api_key])
			}
			redirect_to action: "index"
				
		else
			flash[:error] = "Matchlist thread already running."
			redirect_to action: "index"
		end
	end	
	def get_rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
		#array for player ranks in match to find match average
		rankHash = Hash.new
		#analyzing a match means you have pulled the match list for the ten players in that match.
		#array for the summoners in a specific match. Load all summoners in the database
		summoners_in_match.each do |sum|
			sum_rank = sum_instance.load_summoner_from_api(sum.summoner_name, api_key)
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
		Match.where(:riot_game_id => match_id).update_all(:ladder_rank_of_match => highestRank)
		
	end
	def return_rank_of_match(sum_instance, api_key, summoners_in_match)
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
		return highestRank	
	end
	
	def get_matchlist_from_api_params(match_id, api_key)
		main_match = Match.find_by(riot_game_id: match_id)
		puts "Main match is #{main_match}"
		puts "Analyzed is #{main_match.analyzed.nil?}"
		puts main_match.nil?
		if !main_match.nil? && main_match.analyzed == false then 
			sum_instance = SummonersController.new
			champ_instance = ChampionController.new
			summoners_in_match = PlayerDto.select("summoner_name").joins(:match).where("matches.riot_game_id = #{match_id}")
			get_rank_of_match(sum_instance, match_id, api_key, summoners_in_match)
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
					jsonMatchListArray[i] = get_api_request_as_json(uri)
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
						id = is_nil_ret_char(match.dig("gameId"))
						if !(id	== "-1")
							load_match_from_api(id, api_key)
							sleep(2)
							summoners_in_match = PlayerDto.select("summoner_name").joins(:match).where("matches.riot_game_id = #{id}")
							get_rank_of_match(sum_instance, id, api_key, summoners_in_match)
						end
					end
				end
			end
			main_match.analyzed = true
			main_match.save
			flash[:success] = "Matchlist loaded into database."
		else
			flash[:error] = "Match not loaded in database."
		end
	end

	def read_json_file #load match from api but with params from a post. Could probably do dynamic method parameters and combine with load match from api 
		if Match.find_by(riot_game_id: params[:match_id]).nil?
			load_match_from_api(params[:match_id], params[:api_key])
			redirect_to action: "index"	
		else
			flash[:error] = "Match already loaded in database."
			redirect_to action: "index"	
		end
	end

	def load_match_from_api(match_id, api_key) #Read and save the data from a match by match ID
		
		#uri = "https://na1.api.riotgames.com/lol/match/v4/matches/#{matchId}?api_key=#{params[:api_key]}"
		uri = "https://na1.api.riotgames.com/lol/match/v4/matches/#{match_id}?api_key=#{api_key}"
		parsed_match_input = get_api_request_as_json(uri)
		if parsed_match_input.head == "429" then
			flash[:error] = "API Timeout. Stop making calls for a while."
			return redirect_to 'http://localhost:3000'
		end
		if parsed_match_input.head == "200" && !parsed_match_input.tail.nil? && !Match.exists?(riot_game_id: match_id) then
			
			#jm = json_match
			jm = parsed_match_input.tail
                        #parsed_input["matches"].each do |jm| #jm = json match
			#	Save the match
			summoners_in_match = Array.new
			#create an array to hold the 10 champion positional stats structs we will use later. CPS requires info from many different tables. Better to collect it all here, than pull it out of the data base later
			cps_array = Array.new
			puts jm
			cps_struct = Struct.new(:champion_id, :team_id, :ladder_rank_of_match, :game_version, :role, :participant_dto_id, :team_stats_dto_id, :win, :match_id)
			for k in 0..9 do
				cps_array[k] = cps_struct.new(-1, -1, -1, "none", "none", -1, -1, "null", -1) 
				
			end
			#need another array for the banned champions. We will add to a champions ban rate after we know the ladder rank of the match
			for j in 0..9
				ban_array = Struct.new(:champion_id, :match_id)
			end
			@match = Match.new(riot_game_id: is_nil_ret_int(jm.dig("gameId")), \
					   created_at: jm["gameCreation"], \
					   updated_at: Time.now, \
					   season_id: is_nil_ret_int(jm.dig("seasonId")), \
					   queue_id: is_nil_ret_int(jm.dig("queueId")), \
					   game_version: is_nil_ret_char(jm.dig("gameVersion")), \
					   platform_id: is_nil_ret_char(jm.dig("platformId")), \
					   game_mode: is_nil_ret_char(jm.dig("gameMode")), \
					   map_id: is_nil_ret_int(jm.dig("mapId")), \
					   game_type: is_nil_ret_char(jm.dig("gameType")), \
					   game_duration: is_nil_ret_int(jm.dig("gameDuration")), \
					   game_creation: is_nil_ret_int(jm.dig("gameCreation")), \
					   analyzed: false)
                                @match.save
				puts "The match id is: #{@match.id}"
			#	Save the team stats dto
				j = 0		
				jm["teams"].each do |team|
					@team_stats_dto = TeamStatsDto.new(team_id: is_nil_ret_int(team.dig("teamId")), \
									   first_dragon: is_nil_ret_bool(team.dig("firstDragon")), \
									   first_inhibitor: is_nil_ret_bool(team.dig("firstInhibitor")), \
									   baron_kills: is_nil_ret_int(team.dig("baronKills")), \
									   first_rift_herald: is_nil_ret_bool(team.dig("firstRiftHerald")), \
									   first_baron: is_nil_ret_bool(team.dig("firstBaron")), \
									   rift_herald_kills: is_nil_ret_int(team.dig("riftHeraldKills")), \
									   first_blood: is_nil_ret_bool(team.dig("firstBlood")), \
									   first_tower: is_nil_ret_bool(team.dig("firstTower")), \
									   vilemaw_kills: is_nil_ret_int(team.dig("vilemawKills")), \
									   inhibitor_kills: is_nil_ret_int(team.dig("inhibitorKills")), \
									   tower_kills: is_nil_ret_int(team.dig("tower_kills")), \
									   dominion_victory_score: is_nil_ret_int(team.dig("dominionVictoryScore")), \
									   win: is_nil_ret_char(team.dig("win")), \
									   dragon_kills: is_nil_ret_bool(team.dig("dragonKills")), \
									   match_id: @match.id)
					@team_stats_dto.save!
					k = 0
					#add in the team stats to the first half of the champions
					until k == 5 do
						cps_array[k + j]["match_id"] = @match.id
						cps_array[k + j].team_id = @team_stats_dto.team_id
						puts "The TEAM ID IS:"
						puts @team_stats_dto.team_id
						cps_array[k + j].win = @team_stats_dto.win
						cps_array[k + j].game_version = @match.game_version
						cps_array[k + j].team_stats_dto_id = @team_stats_dto.id
						k = k + 1
					end
					#team bans
					k = 0
					team["bans"].each do |ban|
						@team_bans_dto = TeamBansDto.new(pick_turn: is_nil_ret_int(ban.dig("pickTurn")), \
										 champion_id: is_nil_ret_int(ban.dig("championId")), \
										 team_stats_dto_id: @team_stats_dto.id)
						@team_bans_dto.save
						#get the banned champs
						ban_array[k].champion_id = @team_bans_dto.champion_id
						ban_array[k].match_id = @match.id
						k = k + 1
					end
					j = 5
				end
				k = 0
			#	Save player dto which is inside participant identities	
				jm["participantIdentities"].each do |pi|
				#		puts pi["player"]["summonerName"]
						pp pi
						puts "THIS IS THE START OF PLAYER DTO"
						@player_dto = PlayerDto.new(platform_id: is_nil_ret_char(pi.dig("player", "platformId")), \
									    current_account_id: is_nil_ret_char(pi.dig("player", "currentAccountId")), \
									    summoner_name: is_nil_ret_char(pi.dig("player", "summonerName")), \
									    summoner_id: is_nil_ret_int(pi.dig("player", "summonerId")), \
									    current_platform_id: is_nil_ret_char(pi.dig("player", "currentPlatformId")), \
									    account_id: is_nil_ret_int(pi.dig("player", "accountId")), \
									    match_history_uri: is_nil_ret_char(pi.dig("player", "matchHistoryUri")), \
									    profile_icon: is_nil_ret_int(pi.dig("player", "profileIcon")), \
									    match_id: @match.id, \
									    participant_dto_id: is_nil_ret_int(pi.dig("participantId")))    
						@player_dto.save
						#get the summoners in the match so we can get the rank of the match later, without looping again
						summoners_in_match[k] =  is_nil_ret_char(pi.dig("player", "summonerName"))
						k = k + 1
				end
				k = 0
				#need all the participant dtos before we can calculate win percentage. stuffing them in an array is faster than recalling them from the database. Same with the participant timelines
				pt_array = Array.new
				pd_array = Array.new
				jm["participants"].each do |parti|
					@participant_dto = ParticipantDto.new(participant_id: is_nil_ret_int(parti.dig("participantId")), \
									      team_id: is_nil_ret_int(parti.dig("teamId")), \
									      match_id: @match.id, \
									      champion_id: is_nil_ret_int(parti.dig("championId")), \
	 								      spell_1_id: is_nil_ret_int(parti.dig("spell1Id")), \
	 								      spell_2_id: is_nil_ret_int(parti.dig("spell2Id")), \
									      highest_achieved_season_tier: is_nil_ret_char(parti.dig("highestAchievedSeasonTier")))										
					@participant_dto.save
					pd_array[k] = @participant_dto

					@participant_stats_dto = ParticipantStatsDto.new(first_blood_assist: is_nil_ret_bool(parti.dig("stats", "firstBloodAssist")), \
											vision_score: is_nil_ret_int(parti.dig("stats", "visionScore")), \
										 	magic_damage_dealt_to_champions: is_nil_ret_int(parti.dig("stats", "magicDamageDealtToChampions")), \
									       		damage_dealt_to_objectives: is_nil_ret_int(parti.dig("stats", "damageDealtToObjectives")), \
											total_time_crowd_control_dealt: is_nil_ret_int(parti.dig("stats", "totalTimeCrowdControlDealt")), \
											longest_time_spent_living: is_nil_ret_int(parti.dig("stats", "longestTimeSpentLiving")), \
											triple_kills: is_nil_ret_int(parti.dig("stats", "tripleKills")), \
											node_neutralize_assist: is_nil_ret_int(parti.dig("stats", "nodeNeutralizeAssist")), \
											perk_1_var_1: is_nil_ret_int(parti.dig("stats", "perk1Var1")), \
											perk_1_var_3: is_nil_ret_int(parti.dig("stats", "perk1Var3")), \
											perk_1_var_2: is_nil_ret_int(parti.dig("stats", "perk1Var2")), \
											perk_3_var_3: is_nil_ret_int(parti.dig("stats", "perk3Var3")), \
											perk_3_var_2: is_nil_ret_int(parti.dig("stats", "perk3Var2")), \
											player_score_9: is_nil_ret_int(parti.dig("stats", "playerScore9")), \
											player_score_8: is_nil_ret_int(parti.dig("stats", "playerScore8")), \
											kills: is_nil_ret_int(parti.dig("stats", "kills")), \
											player_score_1: is_nil_ret_int(parti.dig("stats", "playerScore1")), \
											player_score_0: is_nil_ret_int(parti.dig("stats", "playerScore0")), \
											player_score_3: is_nil_ret_int(parti.dig("stats", "playerScore3")), \
											player_score_2: is_nil_ret_int(parti.dig("stats", "playerScore2")), \
											player_score_5: is_nil_ret_int(parti.dig("stats", "playerScore5")), \
											player_score_4: is_nil_ret_int(parti.dig("stats", "playerScore4")), \
											player_score_6: is_nil_ret_int(parti.dig("stats", "playerScore7")), \
											player_score_7: is_nil_ret_int(parti.dig("stats", "playerScore7")), \
											perk_5_var_1: is_nil_ret_int(parti.dig("stats", "perk5Var1")), \
											perk_5_var_3: is_nil_ret_int(parti.dig("stats", "perk5Var3")), \
											perk_5_var_2: is_nil_ret_int(parti.dig("stats", "perk5Var2")), \
											total_score_rank: is_nil_ret_int(parti.dig("stats", "totalScoreRank")), \
											neutral_minions_killed: is_nil_ret_int(parti.dig("stats", "neutralMinionsKilled")), \
											damage_dealt_to_turrets: is_nil_ret_int(parti.dig("stats", "damageDealtToTurrets")), \
											physical_damage_dealt_to_champions: is_nil_ret_int(parti.dig("stats", "physicalDamageDealtToChampions")), \
											node_capture: is_nil_ret_int(parti.dig("stats", "nodeCapture")), \
										        largest_multikill: is_nil_ret_int(parti.dig("stats", "largestMultiKill")), \
											perk_2_var_2: is_nil_ret_int(parti.dig("stats", "perk2Var2")), \
											perk_2_var_3: is_nil_ret_int(parti.dig("stats", "perk2Var3")), \
											total_units_healed: is_nil_ret_int(parti.dig("stats", "totalUnitsHealed")), \
										        perk_2_var_1: is_nil_ret_int(parti.dig("stats", "perk2Var1")), \
											perk_4_var_1: is_nil_ret_int(parti.dig("stats", "perk4Var1")), \
											perk_4_var_2: is_nil_ret_int(parti.dig("stats", "perk4Var2")), \
											perk_4_var_3: is_nil_ret_int(parti.dig("stats", "perk4Var3")), \
											wards_killed: is_nil_ret_int(parti.dig("stats", "wardsKilled")), \
											largest_critical_strike: is_nil_ret_int(parti.dig("stats", "largestCriticalStrike")), \
											largest_killing_spree: is_nil_ret_int(parti.dig("stats", "largestKillingSpree")), \
											quadra_kills: is_nil_ret_int(parti.dig("stats", "quadraKills")), \
											team_objective: is_nil_ret_int(parti.dig("stats", "teamObjective")), \
											magic_damage_dealt: is_nil_ret_int(parti.dig("stats", "magicDamageDealt")), \
											item_2: is_nil_ret_int(parti.dig("stats", "item2")), \
											item_3: is_nil_ret_int(parti.dig("stats", "item3")), \
											item_0: is_nil_ret_int(parti.dig("stats", "item0")), \
											item_6: is_nil_ret_int(parti.dig("stats", "item6")), \
											item_5: is_nil_ret_int(parti.dig("stats", "item5")), \
											item_1: is_nil_ret_int(parti.dig("stats", "item1")), \
											item_4: is_nil_ret_int(parti.dig("stats", "item4")), \
											neutral_minions_killed_team_jungle: is_nil_ret_int(parti.dig("stats", "neutralMinionsKilledTeamJungle")), \
											perk_0: is_nil_ret_int(parti.dig("stats", "perk0")), \
											perk_1: is_nil_ret_int(parti.dig("stats", "perk1")), \
											perk_2: is_nil_ret_int(parti.dig("stats", "perk2")), \
											perk_3: is_nil_ret_int(parti.dig("stats", "perk3")), \
											perk_4: is_nil_ret_int(parti.dig("stats", "perk4")), \
											perk_5: is_nil_ret_int(parti.dig("stats", "perk5")), \
											perk_3_var_1: is_nil_ret_int(parti.dig("stats", "perk3Var1")), \
											damage_self_mitigated: is_nil_ret_int(parti.dig("stats", "damageSelfMitigated")), \
											magical_damage_taken: is_nil_ret_int(parti.dig("stats", "magicalDamageTaken")), \
											first_inhibitor_kill: is_nil_ret_bool(parti.dig("stats", "firstInhibitorKill")), \
											true_damage_taken: is_nil_ret_int(parti.dig("stats", "trueDamageTaken")), \
											node_neutralize: is_nil_ret_int(parti.dig("stats", "nodeNeutralize")), \
											assists: is_nil_ret_int(parti.dig("stats", "assists")), \
											combat_player_score: is_nil_ret_int(parti.dig("stats", "combatPlayerScore")), \
											perk_primary_style: is_nil_ret_int(parti.dig("stats", "perkPrimaryStyle")), \
											gold_spent: is_nil_ret_int(parti.dig("stats", "goldSpent")), \
											true_damage_dealt: is_nil_ret_int(parti.dig("stats", "trueDamageDealt")), \
											participant_id: is_nil_ret_int(parti.dig("stats", "participantId")), \
											total_damage_taken: is_nil_ret_int(parti.dig("stats", "totalDamageTaken")), \
											physical_damage_dealt: is_nil_ret_int(parti.dig("stats", "physicalDamageDealt")), \
											sight_wards_bought_in_game: is_nil_ret_int(parti.dig("stats", "sightWardsBoughtInGame")), \
											total_damage_dealt_to_champions: is_nil_ret_int(parti.dig("stats", "totalDamageDealtToChampions")), \
											physical_damage_taken: is_nil_ret_int(parti.dig("stats", "physicalDamageTaken")), \
											total_player_score: is_nil_ret_int(parti.dig("stats", "totalPlayerScore")), \
											win: is_nil_ret_bool(parti.dig("stats", "win")), \
											objective_player_score: is_nil_ret_int(parti.dig("stats", "objectivePlayerScore")), \
											total_damage_dealt: is_nil_ret_int(parti.dig("stats", "totalDamageDealt")), \
											neutral_minions_killed_enemy_jungle: is_nil_ret_int(parti.dig("stats", "neutralMinionsKilledEnemyJungle")), \
											deaths: is_nil_ret_int(parti.dig("stats", "deaths")), \
											wards_placed: is_nil_ret_int(parti.dig("stats", "wardsPlaced")), \
											perk_sub_style: is_nil_ret_int(parti.dig("stats", "perkSubStyle")), \
											turret_kills: is_nil_ret_int(parti.dig("stats", "turretKills")), \
											first_blood_kill: is_nil_ret_bool(parti.dig("stats", "firstBloodKill")), \
											true_damage_dealt_to_champions: is_nil_ret_int(parti.dig("stats", "trueDamageDealtToChampions")), \
											gold_earned: is_nil_ret_int(parti.dig("stats", "goldEarned")), \
											killing_sprees: is_nil_ret_int(parti.dig("stats", "killingSprees")), \
											unreal_kills: is_nil_ret_int(parti.dig("stats", "unrealKills")), \
											altars_captured: is_nil_ret_int(parti.dig("stats", "altarsCaptured")), \
											first_tower_assist: is_nil_ret_bool(parti.dig("stats", "firstTowerAssist")), \
											champ_level: is_nil_ret_int(parti.dig("stats", "champLevel")), \
											first_tower_kill: is_nil_ret_bool(parti.dig("stats", "firstTowerKill")), \
											double_kills: is_nil_ret_int(parti.dig("stats", "doubleKills")), \
											node_capture_assist: is_nil_ret_int(parti.dig("stats", "nodeCaptureAssist")), \
											inhibitor_kills: is_nil_ret_int(parti.dig("stats", "inhibitorKills")), \
											perk_0_var_1: is_nil_ret_int(parti.dig("stats", "perk0Var1")), \
											perk_0_var_2: is_nil_ret_int(parti.dig("stats", "perk0Var2")), \
											perk_0_var_3: is_nil_ret_int(parti.dig("stats", "perk0Var3")), \
											vision_wards_bought_in_game: is_nil_ret_int(parti.dig("stats", "visionWardsBoughtInGame")), \
											altars_neutralized: is_nil_ret_int(parti.dig("stats", "altarsNeutralized")), \
											penta_kills: is_nil_ret_int(parti.dig("stats", "pentaKills")), \
										        total_heal: is_nil_ret_int(parti.dig("stats", "totalHeal")), \
											time_ccing_others: is_nil_ret_int(parti.dig("stats", "timeCCingOthers")))
					@participant_stats_dto.save
#=begin

					@participant_timeline_dto = ParticipantTimelineDto.new(lane: is_nil_ret_char(parti.dig("timeline", "lane")), \
											       participant_dto_id: is_nil_ret_int(parti.dig("timeline", "participantId")), \
												role: is_nil_ret_char(parti["timeline"]["role"]), \
												creeps_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "0-10")), \
												creeps_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "10-20")), \
												creeps_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "20-30")), \
											       creeps_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "creepsPerMinDeltas", "30-end")), \
											       xp_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "0-10")), \
											       xp_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "10-20")), \
											       xp_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "20-30")), \
											       xp_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "xpPerMinDeltas", "30-end")), \
											       gold_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "0-10")), \
											       gold_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "10-20")), \
											       gold_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "20-30")), \
											       gold_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "goldPerMinDeltas", "30-end")), \
											       damage_taken_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "0-10")), \
											       damage_taken_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "10-20")), \
											       damage_taken_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "20-30")), \
											       damage_taken_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "damageTakenPerMinDeltas", "30-end")), \
											       damage_taken_diff_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "0-10")), \
											       damage_taken_diff_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "10-20")), \
											       damage_taken_diff_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "20-30")), \
											       damage_taken_diff_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "damageTakenDiffPerMinDeltas", "30-end")), \
											       cs_diff_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "0-10")), \
											       cs_diff_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "10-20")), \
											       cs_diff_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "20-30")), \
											       cs_diff_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "csDiffPerMinDeltas", "30-end")), \
											       xp_diff_pmd_0_10: is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "0-10")), \
											       xp_diff_pmd_10_20: is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "10-20")), \
											       xp_diff_pmd_20_30: is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "20-30")), \
											       xp_diff_pmd_30_end: is_nil_ret_int(parti.dig("timeline", "xpDiffPerMinDeltas", "30-end"))
											      )

					
					@participant_timeline_dto.save
					pt_array[k] = @participant_timeline_dto

					
					#=end
					k = k + 1
				end
				
				#cps_array[k] = Struct.new(:champion_id, :match_id, :team_id, :ladder_rank_of_match, :game_version, :role, :participant_dto_id, :team_stats_dto_id, :win, :match_id)
				#loop through the participant dto array and assign the values to a cps struct in the cps struct array
				pd_array.each do |pd|
					for k in 0..9 do
						puts "This is the PD.champion ids:"
						puts pd.champion_id
						puts "cps team ID"
						puts cps_array[k].team_id
						puts "pd.teamid"
						puts pd.team_id
						if cps_array[k].team_id == pd.team_id then
							cps_array[k].champion_id = pd.champion_id
							cps_array[k].participant_dto_id = pd.participant_id
							k = 10
						end
					end
				end
				pt_array.each do |pt|
					for k in 0..9 do
						if pt.participant_dto_id == cps_array[k].participant_dto_id then
							cps_array[k].role = pt.role
							k = 10
						end
					end
				end
				


				#after this, create the champ pos stats object.
				rank_of_match = return_rank_of_match(SummonersController.new, api_key, summoners_in_match)
				@match.ladder_rank_of_match = rank_of_match
				cps_array.each do |cps|
					if cps.win.casecmp("win") || cps.win.casecmp("true") then
						matches_won = 1
						matches_lost = 0
					else
						matches_won = 0
						matches_lost = 1
					end
					@cps_from_db = ChampionPositionalStat.find_by(champions_id:  cps.champion_id, cps_ladder_rank: rank_of_match, cps_position: cps.role)
					if @cps_from_db.nil? then
						@cps_from_db = ChampionPositionalStat.new(pickrate: 1, banrate: 0, num_of_matches_won: matches_won, num_of_matches_lost: matches_lost, \
											   game_version: cps.game_version, cps_ladder_rank: cps.ladder_rank_of_match, \
											   cps_position: cps.role, champions_id: cps.champion_id)
						@cps_from_db.save
					else
						@cps_from_db.pickrate = @cps_from_db.pickrate + 1
						@cps_from_db.num_of_matches_won = @cps_from_db.num_of_matches_won + matches_won				
						@cps_from_db.num_of_matches_lost = @cps_from_db.num_of_matches_lost + matches_lost
						@cps_from_db.save
					end				
				end
			end
		flash[:success] = "Match successfully loaded into database."
                end

	private
		def match_params	
		params.require(:match).permit(:riot_game_id, :created_at, :updated_at, :season_id, :queue_id, :game_version, :platform_id, :game_mode, :map_id, :game_type, :game_duration, :game_creation)
		end

end
