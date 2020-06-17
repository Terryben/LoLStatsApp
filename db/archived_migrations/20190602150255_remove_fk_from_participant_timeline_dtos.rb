class RemoveFkFromParticipantTimelineDtos < ActiveRecord::Migration[5.2]
  def change
	  remove_column :participant_timeline_dtos, :participant_dto_id
	  add_column :participant_timeline_dtos, :participant_dto_id, :integer
  end
end
