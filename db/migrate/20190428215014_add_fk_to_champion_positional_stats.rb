class AddFkToChampionPositionalStats < ActiveRecord::Migration[5.2]
  def change
	  remove_column :champion_positional_stats, :champions_id
	  add_reference :champion_positional_stats, :champions, foreign_key: true
  end
end
