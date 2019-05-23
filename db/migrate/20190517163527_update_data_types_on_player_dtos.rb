class UpdateDataTypesOnPlayerDtos < ActiveRecord::Migration[5.2]
  def change
	  change_column :player_dtos, :current_account_id, 'bigint USING CAST(current_account_id AS bigint)'
	  change_column :player_dtos, :summoner_id, 'bigint USING CAST(summoner_id AS bigint)'

  end
end
