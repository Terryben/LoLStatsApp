class RemoveCharLimitOnSummoners < ActiveRecord::Migration[5.2]
  def change
	  change_column :summoners, :account_id, :string
  end
end
