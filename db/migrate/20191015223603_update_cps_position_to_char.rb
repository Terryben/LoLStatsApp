class UpdateCpsPositionToChar < ActiveRecord::Migration[5.2]
  def change
	  change_column :champion_positional_stats, :cps_position, :string
  end
end
