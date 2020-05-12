class ChangeMatchesLadderRankToString < ActiveRecord::Migration[5.2]
  def change
	  change_column :matches, :ladder_rank_of_match, :string
  end
end
