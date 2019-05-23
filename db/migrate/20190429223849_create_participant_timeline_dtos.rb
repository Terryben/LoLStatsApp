class CreateParticipantTimelineDtos < ActiveRecord::Migration[5.2]
  def change
    #execute "CREATE EXTENSION IF NOT EXISTS hstore;" Need to be superuser to run this
    enable_extension "hstore"    
    create_table :participant_timeline_dtos do |t|
	t.string :lane
	t.string :role
	t.hstore :cs_diff_per_min_delta
	t.hstore :gold_per_min_delta
	t.hstore :xp_diff_per_min_delta
	t.hstore :creeps_per_min_delta
	t.hstore :damage_taken_diff_per_min_delta
	t.hstore :damage_taken_per_min_delta
      t.timestamps
    end
  end
end
