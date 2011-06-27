class CreateProductFormats < ActiveRecord::Migration
  def self.up
    create_table :product_formats do |t|
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :product_formats
  end
end
