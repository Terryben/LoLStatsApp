class AddFkParticipantTimelineDto < ActiveRecord::Migration[5.2]
  def change
	  add_column :participant_timeline_dtos, :participant_dto_id, :integer
	  add_foreign_key :participant_timeline_dtos, :participant_dtos
  end
end
