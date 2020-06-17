class RenamePlayerDtoFkColumn < ActiveRecord::Migration[5.2]
  def change
	  rename_column :player_dtos, :matches_id, :match_id
  end
end
