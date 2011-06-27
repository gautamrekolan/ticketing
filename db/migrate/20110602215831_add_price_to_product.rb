class AddPriceToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :price, :integer
  end

  def self.down
  end
end
