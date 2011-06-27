class RemoveItemIdFromGuest < ActiveRecord::Migration
  def self.up
  remove_column :guests, :item_id
  end

  def self.down
  end
end
