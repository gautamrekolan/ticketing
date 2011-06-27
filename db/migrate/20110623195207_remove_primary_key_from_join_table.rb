class RemovePrimaryKeyFromJoinTable < ActiveRecord::Migration
  def self.up
  remove_column :guests_items, :id
  end

  def self.down
  end
end
