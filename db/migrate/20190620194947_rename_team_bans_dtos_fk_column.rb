class RenameTeamBansDtosFkColumn < ActiveRecord::Migration[5.2]
  def change
	  rename_column :team_stats_dtos, :matches_id, :match_id
  end
end
