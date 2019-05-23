class CreateParticipantStatsDtos < ActiveRecord::Migration[5.2]
  def change
    create_table :participant_stats_dtos do |t|
	t.references :participant_stats_dtos, :participant_dtos, foreign_key: true
	t.boolean :first_blood_assist
	t.decimal :vision_score
	t.decimal :magic_damage_dealt_to_champions
	t.decimal :damage_dealt_to_objectives
	t.integer :total_time_crowd_control_dealt
	t.integer :longest_time_spent_living
	t.integer :triple_kills
	t.integer :node_neutralize_assist
	t.integer :player_score_9
	t.integer :player_score_8
	t.integer :player_score_7
	t.integer :player_score_6
	t.integer :player_score_5
	t.integer :player_score_4
	t.integer :player_score_3
	t.integer :player_score_2
	t.integer :player_score_1
	t.integer :player_score_0
	t.integer :kills
	t.integer :total_score_rank
	t.integer :neutral_minions_killed
	t.decimal :damage_dealt_to_turrets
	t.decimal :physical_damage_dealt_to_champions
	t.integer :node_capture
	t.integer :largest_multikill
	t.integer :total_units_healed
	t.integer :wards_killed
	t.integer :largest_critical_strike
	t.integer :largest_killing_spree
	t.integer :quadra_kills
	t.integer :team_objective
	t.integer :magic_damage_dealt
	t.integer :neutral_minions_killed_team_jungle
	t.integer :dragon_kills
	t.integer :perk_1_var_1
	t.integer :perk_1_var_2
	t.integer :perk_1_var_3
	t.integer :perk_3_var_1
	t.integer :perk_3_var_2
	t.integer :perk_3_var_3
	t.integer :perk_5_var_1
	t.integer :perk_5_var_2
	t.integer :perk_5_var_3
	t.integer :perk_2_var_1
	t.integer :perk_2_var_2
	t.integer :perk_2_var_3
	t.integer :perk_4_var_1
	t.integer :perk_4_var_2
	t.integer :perk_4_var_3
	t.integer :item_0
	t.integer :item_1
	t.integer :item_2
	t.integer :item_3
	t.integer :item_4
	t.integer :item_5
	t.integer :item_6
	t.decimal :damage_self_mitigated
	t.decimal :magical_damage_taken
	t.boolean :first_inhibitor_kill
	t.decimal :true_damage_taken
	t.integer :node_neutralize
	t.integer :assists
	t.integer :combat_player_score
	t.integer :perk_primary_style
	t.integer :gold_spent
	t.decimal :true_damage_dealt
	t.integer :participant_id
	t.decimal :total_damage_taken
	t.decimal :physical_damage_taken
	t.integer :sight_wards_bought_in_game
	t.decimal :total_damage_dealt_to_champions
	t.decimal :physical_damage_taken
	t.integer :total_player_score
	t.boolean :win
	t.integer :objective_player_score
	t.decimal :total_damage_dealt
	t.integer :perk_0
	t.integer :perk_1
	t.integer :perk_2
	t.integer :perk_3
	t.integer :perk_4
	t.integer :perk_5
	t.integer :neutral_minions_killed_enemy_jungle
	t.integer :deaths
	t.integer :wards_placed
	t.integer :perk_sub_style
	t.integer :turret_kills
	t.integer :gold_earned
	t.boolean :first_blood_kill
	t.decimal :true_damage_dealt_to_champions
	t.integer :killing_sprees
	t.integer :unreal_kills
	t.integer :altars_captured
	t.integer :champ_level
	t.boolean :first_tower_assist
	t.boolean :first_tower_kill
	t.integer :double_kills
	t.integer :node_capture_assist
	t.integer :inhibitor_kills
	t.boolean :first_inhibitor_assist
	t.integer :perk_0_var_1
	t.integer :perk_0_var_2
	t.integer :perk_0_var_3
	t.integer :vision_wards_bought_in_game
	t.integer :altars_neutralized
	t.integer :penta_kills
	t.decimal :total_heal
	t.integer :total_minions_killed
	t.decimal :time_ccing_others
      t.timestamps
    end
  end
end
