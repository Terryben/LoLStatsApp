class RemoveColumnsFromParticipantTimelineDtos < ActiveRecord::Migration[5.2]
  def change
	  remove_column :participant_timeline_dtos, :cs_diff_per_min_delta
	  remove_column :participant_timeline_dtos, :gold_per_min_delta
	  remove_column :participant_timeline_dtos, :xp_diff_per_min_delta
	  remove_column :participant_timeline_dtos, :creeps_per_min_delta
	  remove_column :participant_timeline_dtos, :damage_taken_diff_per_min_delta
	  remove_column :participant_timeline_dtos, :damage_taken_per_min_delta

	  add_column :participant_timeline_dtos, :creeps_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :creeps_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :creeps_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :creeps_pmd_30_end, :decimal


	  add_column :participant_timeline_dtos, :xp_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :xp_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :xp_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :xp_pmd_30_end, :decimal


	  add_column :participant_timeline_dtos, :gold_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :gold_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :gold_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :gold_pmd_30_end, :decimal


	  add_column :participant_timeline_dtos, :damage_taken_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_pmd_30_end, :decimal


	  add_column :participant_timeline_dtos, :damage_taken_diff_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_diff_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_diff_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :damage_taken_diff_pmd_30_end, :decimal
  end
end
