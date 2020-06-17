class RemoveFksFromMatches < ActiveRecord::Migration[5.2]
  def change
	  remove_column :matches, :player_dto_id
	  remove_column :matches, :team_id
	  remove_column :matches, :participant_id
  end
end
