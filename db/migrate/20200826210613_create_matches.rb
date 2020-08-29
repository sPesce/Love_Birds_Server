class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.integer :sender
      t.integer :reciever
      t.integer :sender_status
      t.integer :reciever_status

      t.timestamps
    end
  end
end
