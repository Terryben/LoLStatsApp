class CreateParticipantDtos < ActiveRecord::Migration[5.2]
  def change
    create_table :participant_dtos do |t|    
	t.references :matches, foreign_key: true 
	t.references :champions, foreign_key: true
        t.integer :team_id
	t.integer :spell_2_id
	t.integer :spell_1_id
	t.string :highest_achieved_season_tier	
      t.timestamps
    end
  end
end
