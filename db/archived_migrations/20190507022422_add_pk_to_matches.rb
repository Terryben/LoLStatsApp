class AddPkToMatches < ActiveRecord::Migration[5.2]
  def change
	  remove_column :participant_dtos, :matches_id
	  remove_column :team_stats_dtos, :match_id
	  remove_column :player_dtos, :match_id
	  remove_column :matches, :id

	  add_column :matches, :id, :primary_key

	  add_reference :participant_dtos, :matches, index: true, foreign_key: true
	  add_reference :team_stats_dtos, :matches, index: true, foreign_key: true
	  add_reference :player_dtos, :matches, index: true, foreign_key: true
  end
end
