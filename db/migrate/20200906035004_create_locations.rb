class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :zip
      t.decimal :lat
      t.decimal :long      
    end
  end
end
