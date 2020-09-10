class CreateMessagesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :messages_tables do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.string :body
    end
  end
end
