class UpdateTeamStatsDtosTeamIdToInteger < ActiveRecord::Migration[5.2]
  def change
	  change_column :team_stats_dtos, :team_id, 'integer USING CAST(team_id AS integer)'
  end
end
