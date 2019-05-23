class ChampionPositionalStats < ActiveRecord::Migration[5.2]
  def change
	  create_table :champion_positional_stats do |t|
		  t.integer :champion_id
		  t.decimal :winrate
		  t.decimal :pickrate
		  t.decimal :banrate
		  t.decimal :num_of_matches_won
		  t.decimal :num_of_matches_lost
		  t.string :game_version
		  t.integer :cps_ladder_rank #this is an enum in the database
		  t.integer :cps_position #this is an enum in the database
	  end
		  add_reference :champion_positional_stats, :champions, foreign_key: true

  end
end
