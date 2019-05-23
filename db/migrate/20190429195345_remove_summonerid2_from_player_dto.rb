class RemoveSummonerid2FromPlayerDto < ActiveRecord::Migration[5.2]
  def change
	  rename_column :player_dtos, :summoner_id2, :summoner_id_string
  end
end
