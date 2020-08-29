class CreateUserCaretakers < ActiveRecord::Migration[6.0]
  def change
    create_table :user_caretakers do |t|
      t.integer :user_id
      t.integer :caretaker_id
      t.integer :control_level

      t.timestamps
    end
  end
end
