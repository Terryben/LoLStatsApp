class AddColumnsTwoToSummoners < ActiveRecord::Migration[5.2]
  def change
	add_column :summoners, :queue_type, :string
	add_column :summoners, :summoner_name, :string
	add_column :summoners, :rank, :string
	add_column :summoners, :tier, :string
	add_column :summoners, :league_id, :string	
  end
end
