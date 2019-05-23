class CreateTeamStatsDtos < ActiveRecord::Migration[5.2]
  def change
    create_table :team_stats_dtos do |t|
	t.boolean :first_dragon
	t.boolean :first_inhibitor
	t.integer :baron_kills
	t.boolean :first_rift_herald
	t.boolean :first_baron
	t.integer :rift_herald_kills
	t.boolean :first_blood
	t.boolean :team_id
	t.boolean :first_tower
	t.integer :vilemaw_kills
	t.integer :inhibitor_kills
	t.integer :tower_kills
	t.integer :dominion_victory_score
	t.string :win
	t.integer :dragon_kills
      t.timestamps
    end
  end
end
