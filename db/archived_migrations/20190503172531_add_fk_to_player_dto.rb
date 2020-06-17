class AddFkToPlayerDto < ActiveRecord::Migration[5.2]
  def change
	  add_column :player_dtos, :match_id, :integer
	  add_foreign_key :player_dtos, :matches
  end
end
