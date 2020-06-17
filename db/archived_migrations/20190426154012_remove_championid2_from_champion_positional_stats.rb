class RemoveChampionid2FromChampionPositionalStats < ActiveRecord::Migration[5.2]
  def change
	  remove_column :champion_positional_stats, :champion_id, :integer
	  add_reference :champion_positional_stats, :champions
  end
end
