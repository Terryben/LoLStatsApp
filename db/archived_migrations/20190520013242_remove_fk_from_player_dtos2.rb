class RemoveFkFromPlayerDtos2 < ActiveRecord::Migration[5.2]
  def change
	  remove_column :participant_dtos, :champions_id
	  add_column :participant_dtos, :champion_id, :integer
  end
end
