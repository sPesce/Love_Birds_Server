class RemoveCategoryFromDisabilities < ActiveRecord::Migration[6.0]
  def change
    remove_column :disabilities, :category, :string
  end
end
