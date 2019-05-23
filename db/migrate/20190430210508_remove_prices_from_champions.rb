class RemovePricesFromChampions < ActiveRecord::Migration[5.2]
  def change
	  remove_column :champions, :price_be
	  remove_column :champions, :price_ip
	  remove_column :champions, :stat_id
  end
end
