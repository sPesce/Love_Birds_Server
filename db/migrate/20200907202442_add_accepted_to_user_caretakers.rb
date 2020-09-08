class AddAcceptedToUserCaretakers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_caretakers, :accepted, :string
  end
end
