class AddRanksToChampStats < ActiveRecord::Migration[5.2]
  def change
	  add_column :champions, :num_bronze_games, :integer
	  add_column :champions, :num_iron_games, :integer
	  add_column :champions, :num_silver_games, :integer
	  add_column :champions, :num_gold_games, :integer
	  add_column :champions, :num_platinum_games, :integer
	  add_column :champions, :num_diamond_games, :integer
	  add_column :champions, :num_master_games, :integer
	  add_column :champions, :num_grandmaster_games, :integer
	  add_column :champions, :num_challenger_games, :integer
	  
	  add_column :champions, :iron_winrate, :decimal
	  add_column :champions, :bronze_winrate, :decimal
	  add_column :champions, :silver_winrate, :decimal
	  add_column :champions, :gold_winrate, :decimal
	  add_column :champions, :platinum_winrate, :decimal
	  add_column :champions, :diamond_winrate, :decimal
	  add_column :champions, :master_winrate, :decimal
	  add_column :champions, :grandmaster_winrate, :decimal
	  add_column :champions, :challenger_winrate, :decimal

  end
end
