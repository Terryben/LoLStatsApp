class UpdateChampIdNameOnCps < ActiveRecord::Migration[5.2]
  def change
	  rename_column :champion_positional_stats, :champions_id, :champion_id 
  end
end
