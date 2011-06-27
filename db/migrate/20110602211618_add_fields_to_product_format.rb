class AddFieldsToProductFormat < ActiveRecord::Migration
  def self.up
  add_column :product_formats, :height, :integer
  add_column :product_formats, :width, :integer
  end

  def self.down
  end
end
