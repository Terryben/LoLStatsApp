class CreateTeamBansDtos < ActiveRecord::Migration[5.2]
  def change
    create_table :team_bans_dtos do |t|
	t.references :team_stats_dtos, foreign_key: true
	t.integer :pick_turn
	t.integer :champion_id
      t.timestamps
    end
  end
end
