class AddPhysicalDamageDealtToParticipantStatsDtos < ActiveRecord::Migration[5.2]
  def change
	  add_column :participant_stats_dtos, :physical_damage_dealt, :bigint
  end
end
