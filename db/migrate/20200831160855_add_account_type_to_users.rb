class AddAccountTypeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_type, :string
  end
end
