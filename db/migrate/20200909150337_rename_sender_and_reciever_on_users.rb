class RenameSenderAndRecieverOnUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :matches do |t|
      t.rename :sender, :user_id
      t.rename :reciever, :matched_user_id
    end
  end
end
