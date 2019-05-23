class RemoveFkFromPlayerDtos < ActiveRecord::Migration[5.2]
  def change
	  remove_column :player_dtos, :summoner_id
	  add_column :player_dtos, :summoner_id, :bigint
  end
end
