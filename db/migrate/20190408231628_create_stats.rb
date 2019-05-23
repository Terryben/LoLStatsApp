class CreateStats < ActiveRecord::Migration[5.2]
  def change
    create_table :stats do |t|
      t.string :name
      t.float :percentage

      t.timestamps
    end
  end
end
