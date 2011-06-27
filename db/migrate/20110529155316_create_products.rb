class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :product_type_id
      t.integer :product_format_id
      t.integer :theme_id
    end
  end

  def self.down
    drop_table :products
  end
end
