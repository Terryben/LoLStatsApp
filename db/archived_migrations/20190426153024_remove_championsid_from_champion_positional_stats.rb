class RemoveChampionsidFromChampionPositionalStats < ActiveRecord::Migration[5.2]
  def change
	  remove_column :champion_positional_stats, :champions_id, :integer
  end
end
