class MatchesController < ApplicationController
	require "json"
	require "rubygems"
	require "pp"
	
	def index
		@matches = Match.all
	end
	
	def show
		@match = Match.find(params[:id])
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
					@team_stats_dto = TeamStatsDto.new(team_id: team["teamId"], first_dragon: team["firstDragon"], first_inhibitor: team["firstInhibitor"], \
									     baron_kills: team["baronKills"], first_rift_herald: team["firstRiftHerald"], first_baron: team["firstBaron"], \
									     rift_herald_kills: team["riftHeraldKills"], first_blood: team["firstBlood"], first_tower: team["firstTower"], \
									     vilemaw_kills: team["vilemawKills"], inhibitor_kills: team["inhibitorKills"], tower_kills: team["tower_kills"], \
									     dominion_victory_score: team["dominionVictoryScore"], win: team["win"], dragon_kills: team["dragonKills"], \
									     matches_id: @match.id)
					@team_stats_dto.save
					#team bans
					team["bans"].each do |ban|
						@team_bans_dto = TeamBansDto.new(pick_turn: ban["pickTurn"], champion_id: ban["championId"], team_stats_dtos_id: @team_stats_dto.id)
						@team_bans_dto.save
					end
				end
			#	Save player dto which is inside participant identities	
				jm["participantIdentities"].each do |pi|
				#		puts pi["player"]["summonerName"]
				#		pp pi
						@player_dto = PlayerDto.new(platform_id: pi["player"]["platformId"], current_account_id: pi["player"]["currentAccountId"], \
									    summoner_name: pi["player"]["summonerName"], summoner_id: pi["player"]["summonerId"], \
									    current_platform_id: pi["player"]["currentPlatformId"], account_id: pi["player"]["accountId"], \
									    match_history_uri: pi["player"]["matchHistoryUri"], profile_icon: pi["player"]["profileIcon"], \
									    participant_dto_id: pi["participantId"])    
						@player_dto.save
				end
				
				jm["participants"].each do |parti|
					@participant_dto = ParticipantDto.new(participant_id: parti["participantId"], team_id: parti["teamId"], matches_id: @match.id, champion_id: parti["championId"], \
									     spell_1_id: parti["spell1Id"], spell_2_id: parti["spell2Id"], highest_achieved_season_tier: parti["highestAchievedSeasonTier"])										
					@participant_dto.save

					@participant_stats_dto = ParticipantStatsDto.new(first_blood_assist: parti["stats"]["firstBloodAssist"], \
											vision_score: parti["stats"]["visionScore"], \
										 	magic_damage_dealt_to_champions: parti["stats"]["magicDamageDealtToChampions"], \
									       		damage_dealt_to_objectives: parti["stats"]["damageDealtToObjectives"], \
											total_time_crowd_control_dealt: parti["stats"]["totalTimeCrowdControlDealt"], \
											longest_time_spent_living: parti["stats"]["longestTimeSpentLiving"], \
											triple_kills: parti["stats"]["tripleKills"], \
											node_neutralize_assist: parti["stats"]["nodeNeutralizeAssist"], \
											perk_1_var_1: parti["stats"]["perk1Var1"], \
											perk_1_var_3: parti["stats"]["perk1Var3"], \
											perk_1_var_2: parti["stats"]["perk1Var2"], \
											perk_3_var_3: parti["stats"]["perk3Var3"], \
											perk_3_var_2: parti["stats"]["perk3Var2"], \
											player_score_9: parti["stats"]["playerScore9"], \
											player_score_8: parti["stats"]["playerScore8"], \
											kills: parti["stats"]["kills"], \
											player_score_1: parti["stats"]["playerScore1"], \
											player_score_0: parti["stats"]["playerScore0"], \
											player_score_3: parti["stats"]["playerScore3"], \
											player_score_2: parti["stats"]["playerScore2"], \
											player_score_5: parti["stats"]["playerScore5"], \
											player_score_4: parti["stats"]["playerScore4"], \
											player_score_6: parti["stats"]["playerScore7"], \
											player_score_7: parti["stats"]["playerScore7"], \
											perk_5_var_1: parti["stats"]["perk5Var1"], \
											perk_5_var_3: parti["stats"]["perk5Var3"], \
											perk_5_var_2: parti["stats"]["perk5Var2"], \
											total_score_rank: parti["stats"]["totalScoreRank"], \
											neutral_minions_killed: parti["stats"]["neutralMinionsKilled"], \
											damage_dealt_to_turrets: parti["stats"]["damageDealtToTurrets"], \
											physical_damage_dealt_to_champions: parti["stats"]["physicalDamageDealtToChampions"], \
											node_capture: parti["stats"]["nodeCapture"], \
										        largest_multikill: parti["stats"]["largestMultiKill"], \
											perk_2_var_2: parti["stats"]["perk2Var2"], \
											perk_2_var_3: parti["stats"]["perk2Var3"], \
											total_units_healed: parti["stats"]["totalUnitsHealed"], \
										        perk_2_var_1: parti["stats"]["perk2Var1"], \
											perk_4_var_1: parti["stats"]["perk4Var1"], \
											perk_4_var_2: parti["stats"]["perk4Var2"], \
											perk_4_var_3: parti["stats"]["perk4Var3"], \
											wards_killed: parti["stats"]["wardsKilled"], \
											largest_critical_strike: parti["stats"]["largestCriticalStrike"], \
											largest_killing_spree: parti["stats"]["largestKillingSpree"], \
											quadra_kills: parti["stats"]["quadraKills"], \
											team_objective: parti["stats"]["teamObjective"], \
											magic_damage_dealt: parti["stats"]["magicDamageDealt"], \
											item_2: parti["stats"]["item_2"], \
											item_3: parti["stats"]["item_3"], \
											item_0: parti["stats"]["item_0"], \
											item_6: parti["stats"]["item_6"], \
											item_5: parti["stats"]["item_5"], \
											item_1: parti["stats"]["item_1"], \
											item_4: parti["stats"]["item_4"], \
											neutral_minions_killed_team_jungle: parti["stats"]["neutralMinionsKilledTeamJungle"], \
											perk_0: parti["stats"]["perk0"], \
											perk_1: parti["stats"]["perk1"], \
											perk_2: parti["stats"]["perk2"], \
											perk_3: parti["stats"]["perk3"], \
											perk_4: parti["stats"]["perk4"], \
											perk_5: parti["stats"]["perk5"], \
											perk_3_var_1: parti["stats"]["perk3Var1"], \
											damage_self_mitigated: parti["stats"]["damageSelfMitigated"], \
											magical_damage_taken: parti["stats"]["magicalDamageTaken"], \
											first_inhibitor_kill: parti["stats"]["firstInhibitorKill"], \
											true_damage_taken: parti["stats"]["trueDamageTaken"], \
											node_neutralize: parti["stats"]["nodeNeutralize"], \
											assists: parti["stats"]["assists"], \
											combat_player_score: parti["stats"]["combatPlayerScore"], \
											perk_primary_style: parti["stats"]["perkPrimaryStyle"], \
											gold_spent: parti["stats"]["goldSpent"], \
											true_damage_dealt: parti["stats"]["trueDamageDealt"], \
											participant_id: parti["stats"]["participantId"], \
											total_damage_taken: parti["stats"]["totalDamageTaken"], \
											physical_damage_dealt: parti["stats"]["physicalDamageDealt"], \
											sight_wards_bought_in_game: parti["stats"]["sightWardsBoughtInGame"], \
											total_damage_dealt_to_champions: parti["stats"]["totalDamageDealtToChampions"], \
											physical_damage_taken: parti["stats"]["physicalDamageTaken"], \
											total_player_score: parti["stats"]["totalPlayerScore"], \
											win: parti["stats"]["win"], \
											objective_player_score: parti["stats"]["objectivePlayerScore"], \
											total_damage_dealt: parti["stats"]["totalDamageDealt"], \
											neutral_minions_killed_enemy_jungle: parti["stats"]["neutralMinionsKilledEnemyJungle"], \
											deaths: parti["stats"]["deaths"], \
											wards_placed: parti["stats"]["wardsPlaced"], \
											perk_sub_style: parti["stats"]["perkSubStyle"], \
											turret_kills: parti["stats"]["turretKills"], \
											first_blood_kill: parti["stats"]["firstBloodKill"], \
											true_damage_dealt_to_champions: parti["stats"]["trueDamageDealtToChampions"], \
											gold_earned: parti["stats"]["goldEarned"], \
											killing_sprees: parti["stats"]["killing_sprees"], \
											unreal_kills: parti["stats"]["unrealKills"], \
											altars_captured: parti["stats"]["altarsCaptured"], \
											first_tower_assist: parti["stats"]["firstTowerAssist"], \
											champ_level: parti["stats"]["champLevel"], \
											first_tower_kill: parti["stats"]["firstTowerKill"], \
											double_kills: parti["stats"]["doubleKills"], \
											node_capture_assist: parti["stats"]["nodeCaptureAssist"], \
											inhibitor_kills: parti["stats"]["inhibitorKills"], \
											perk_0_var_1: parti["stats"]["perk0Var1"], \
											perk_0_var_2: parti["stats"]["perk0Var2"], \
											perk_0_var_3: parti["stats"]["perk0Var3"], \
											vision_wards_bought_in_game: parti["stats"]["visionWardsBoughtInGame"], \
											altars_neutralized: parti["stats"]["altarsNeutralized"], \
											penta_kills: parti["stats"]["pentaKills"], \
										        total_heal: parti["stats"]["totalHeal"], \
											time_ccing_others: parti["stats"]["timeCCingOthers"])
					@participant_stats_dto.save

				#	@participant_timeline_dto = ParticipantTimelineDto.new(lane: parti["stats"]["lane"], \
				#						       	       participant_dto_id: parti["stats"]["participantId"], \
				#							       role: parti["stats"]["role"], \
					puts "Does this pull the 10-20 stats?"
					pp parti["timeline"]["csDiffPerMinDeltas"]							       	       

					#puts parti["stats"]["firstBloodAssist"]

				end

	
                        end
                end

	private
		def match_params	
		params.require(:match).permit(:riot_game_id, :created_at, :updated_at, :season_id, :queue_id, :game_version, :platform_id, :game_mode, :map_id, :game_type, :game_duration, :game_creation)
		end

end
