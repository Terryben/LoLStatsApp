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

	def read_json_file
                        file = open("F:/Downloads/matches1.json")
                        json = file.read
			#run into invalid characters. Double convert to force valid characters
			json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
			json.encode!('UTF-8', 'UTF-16')


                        parsed_input = JSON.parse(json)

                        parsed_input["matches"].each do |jm| #jm = json match
			#	Save the match
                                @match = Match.new(riot_game_id: jm["gameId"], created_at: jm["gameCreation"], updated_at: Time.now, season_id: jm["seasonId"], queue_id: jm["queueId"],\
                                           game_version: jm["gameVersion"], platform_id: jm["platformId"], game_mode: jm["gameMode"], map_id: jm["mapId"], \
                                           game_type: jm["gameType"], game_duration: jm["gameDuration"], game_creation: jm["gameCreation"])
                                @match.save
			#	Save the team stats dto		
				jm["teams"].each do |team|
					@team_stats_dto = TeamStatsDto.new(team_id: is_nil_ret_bool(team.dig("teamId")), \
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
					@team_stats_dto.save
					#team bans
					team["bans"].each do |ban|
						@team_bans_dto = TeamBansDto.new(pick_turn: is_nil_ret_int(ban.dig("pickTurn")), \
										 champion_id: is_nil_ret_int(ban.dig("championId")), \
										 team_stats_dto_id: @team_stats_dto.id)
						@team_bans_dto.save
					end
				end
			#	Save player dto which is inside participant identities	
				jm["participantIdentities"].each do |pi|
				#		puts pi["player"]["summonerName"]
				#		pp pi
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
						puts "PLAYER DTO HAS JUST BEEN SAVED"
				end
				
				jm["participants"].each do |parti|
					@participant_dto = ParticipantDto.new(participant_id: is_nil_ret_int(parti.dig("participantId")), \
									      team_id: is_nil_ret_int(parti.dig("teamId")), \
									      match_id: @match.id, \
									      champion_id: is_nil_ret_int(parti.dig("championId")), \
	 								      spell_1_id: is_nil_ret_int(parti.dig("spell1Id")), \
	 								      spell_2_id: is_nil_ret_int(parti.dig("spell2Id")), \
									      highest_achieved_season_tier: is_nil_ret_char(parti.dig("highestAchievedSeasonTier")))										
					@participant_dto.save

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
					
					
					#=end
					#puts "Does this pull the 10-20 stats?"
					#puts is_nil_ret_int(parti["timeline"]["csDiffPerMinDeltas"])
				#	unless parti["timeline"]["csDiffPerMinDeltas"].nil?
				#		puts parti["timeline"]["csDiffPerMinDeltas"]
				#		puts parti["timeline"]["csDiffPerMinDeltas"].class
				#		puts parti["timeline"]["csDiffPerMinDeltas"]["0-10"]
				#	puts parti["stats"]["firstBloodAssist"]
				#	end

				end

	
                        end
                end

	private
		def match_params	
		params.require(:match).permit(:riot_game_id, :created_at, :updated_at, :season_id, :queue_id, :game_version, :platform_id, :game_mode, :map_id, :game_type, :game_duration, :game_creation)
		end

end
