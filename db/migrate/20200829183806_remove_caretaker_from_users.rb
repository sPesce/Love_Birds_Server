class RemoveCaretakerFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :caretaker, :boolean
  end
end
