class RemoveWinrateFromCps < ActiveRecord::Migration[5.2]
  def change
	  remove_column :champion_positional_stats, :winrate 
  end
end
