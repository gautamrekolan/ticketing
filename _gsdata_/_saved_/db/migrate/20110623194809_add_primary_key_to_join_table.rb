class AddPrimaryKeyToJoinTable < ActiveRecord::Migration
  def self.up
  add_column :guests_items, :id, :primary_key
  end

  def self.down
  end
end
