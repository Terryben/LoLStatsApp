class ChangeMatchidInTeamStatsDto < ActiveRecord::Migration[5.2]
  def change
	  change_column :team_stats_dtos, :match_id, :decimal
  end
end
