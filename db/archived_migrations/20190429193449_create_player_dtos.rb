class CreatePlayerDtos < ActiveRecord::Migration[5.2]
  def change
    create_table :player_dtos do |t|
      t.string :current_platform_id
      t.string :summoner_name
      t.string :match_history_uri
      t.string :platform_id
      t.string :current_account_id
      t.references :summoner, foreign_key: true
      t.string :summoner_id2
      t.integer :participant_dto_id
      t.integer :profile_icon      
      t.timestamps
    end
  end
end
