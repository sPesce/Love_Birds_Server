class RemovePicIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :pic_id, :integer
  end
end
