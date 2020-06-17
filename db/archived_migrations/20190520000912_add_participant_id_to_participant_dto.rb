class AddParticipantIdToParticipantDto < ActiveRecord::Migration[5.2]
  def change
	  add_column :participant_dtos, :participant_id, :integer
  end
end
