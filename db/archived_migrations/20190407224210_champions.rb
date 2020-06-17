class Champions < ActiveRecord::Migration[5.2]
  def change
	  add_column :champions, :name, :string
	  add_column :champions, :price_be, :integer
	  add_column :champions, :price_ip, :integer
	  add_column :champions, :title, :string, :limit => 50
	  add_column :champions, :winrate, :float
	  add_column :champions, :pickrate, :float
  end
end
