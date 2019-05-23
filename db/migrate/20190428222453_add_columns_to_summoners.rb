class AddColumnsToSummoners < ActiveRecord::Migration[5.2]
  def change
	  add_column :summoners, :summoner_id, :string
	  add_column :summoners, :summoner_level, :decimal
	  add_column :summoners, :puuid, :string
	  add_column :summoners, :profile_icon_id, :integer
  end
end
