class AddAnalyzeToMatches < ActiveRecord::Migration[5.2]
  def change
	  add_column :matches, :analyzed, :boolean
  end
end
