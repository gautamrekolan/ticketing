class AddEnvelopeToProductTypes < ActiveRecord::Migration
  def self.up
    add_column :product_types, :envelope, :boolean
  end

  def self.down
  end
end
