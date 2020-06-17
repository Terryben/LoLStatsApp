class UpdateCpsLadderRankToCharVar < ActiveRecord::Migration[5.2]
  def change
	  change_column :champion_positional_stats, :cps_ladder_rank, :string
  end
end
