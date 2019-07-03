class RenameSummonerNamesAgain < ActiveRecord::Migration[5.2]
  def change
	  rename_column :summoners, :summoner_level, :level
	  remove_column :summoners, :summoner_id
	  remove_column :summoners, :summoner_name

  end
end
