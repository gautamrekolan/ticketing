class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :product_id
      t.integer :price
      t.integer :quantity_ordered
      t.integer :quantity_despatched

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
