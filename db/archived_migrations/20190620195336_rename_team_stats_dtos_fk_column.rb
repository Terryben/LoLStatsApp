class RenameTeamStatsDtosFkColumn < ActiveRecord::Migration[5.2]
  def change
	  rename_column :team_bans_dtos, :team_stats_dtos_id, :team_stats_dto_id
	  rename_column :participant_dtos, :matches_id, :match_id
	  rename_column :participant_stats_dtos, :participant_dtos_id, :participant_dto_id
	  remove_column :participant_stats_dtos, :participant_stats_dtos_id
  end
end
