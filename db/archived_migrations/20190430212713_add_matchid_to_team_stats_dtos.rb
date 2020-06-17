class AddMatchidToTeamStatsDtos < ActiveRecord::Migration[5.2]
  def change
	  add_column :team_stats_dtos, :match_id, :integer
  end
end
