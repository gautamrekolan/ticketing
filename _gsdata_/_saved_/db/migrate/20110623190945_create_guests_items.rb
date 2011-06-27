class CreateGuestsItems < ActiveRecord::Migration
  def self.up
  create_table :guests_items, :id => false do |t|
    t.references :guest
    t.references :item
  end
  end

  def self.down
  end
end
