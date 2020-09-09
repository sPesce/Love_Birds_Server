class AddPicToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pic, :string
  end
end
