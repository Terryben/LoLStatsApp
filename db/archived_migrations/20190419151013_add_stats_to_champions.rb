class AddStatsToChampions < ActiveRecord::Migration[5.2]
  def change
	  add_reference :champions, :stat, foreign_key: true
  end
end
