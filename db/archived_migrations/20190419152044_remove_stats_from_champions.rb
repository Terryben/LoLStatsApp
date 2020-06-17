class RemoveStatsFromChampions < ActiveRecord::Migration[5.2]
  def change
    remove_column :champions, :winrate, :float
    remove_column :champions, :pickrate, :float
  end
end
