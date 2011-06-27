class AddFoldedToProductFormats < ActiveRecord::Migration
  def self.up
    add_column :product_formats, :style, :string
  end

  def self.down
  end
end
