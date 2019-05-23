class Summoners < ActiveRecord::Migration[5.2]
  def change
	  add_column :summoners, :name, :string
  end
end
