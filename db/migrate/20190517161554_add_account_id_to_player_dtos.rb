class AddAccountIdToPlayerDtos < ActiveRecord::Migration[5.2]
  def change
	  add_column :player_dtos, :account_id, :bigint
  end
end
