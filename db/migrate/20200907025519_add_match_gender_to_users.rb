class AddMatchGenderToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :match_gender, :string
  end
end
