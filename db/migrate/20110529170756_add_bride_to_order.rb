class AddBrideToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :bride_name, :string
  end

  def self.down
    remove_column :orders, :bride_name
  end
end
