class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :password_digest
      t.string :bio
      t.string :zip_code
      t.boolean :caretaker
      t.boolean :validated
      t.boolean :admin

      t.timestamps
    end
  end
end
