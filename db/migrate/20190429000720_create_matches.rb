class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches, id: false do |t|
      t.decimal :id, primary_key: true
      t.timestamps
      t.integer :season_id
      t.integer :queue_id
      t.string :game_version
      t.string :platform_id
      t.string :game_mode
      t.integer :map_id
      t.string :game_type
      t.decimal :game_duration
      t.decimal :game_creation
      t.decimal :player_dto_id, array: true, default: [10]
      t.decimal :team_id, array: true, default: [2]
      t.decimal :participant_id, array: true, default: [10]
      t.integer :ladder_rank_of_match
    end
  end
end
