class AddColumnsToPtDtos < ActiveRecord::Migration[5.2]
  def change
	  add_column :participant_timeline_dtos, :cs_diff_pmd_0_10, :decimal
	  add_column :participant_timeline_dtos, :cs_diff_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :cs_diff_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :cs_diff_pmd_30_end, :decimal


	  add_column :participant_timeline_dtos, :xp_diff_pmd_30_end, :decimal
	  add_column :participant_timeline_dtos, :xp_diff_pmd_20_30, :decimal
	  add_column :participant_timeline_dtos, :xp_diff_pmd_10_20, :decimal
	  add_column :participant_timeline_dtos, :xp_diff_pmd_0_10, :decimal
  end
end
