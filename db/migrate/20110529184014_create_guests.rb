class CreateGuests < ActiveRecord::Migration
  def self.up
    create_table :guests do |t|
      t.string :name_on_envelope
      t.string :name_on_invitation
      t.string :address
      t.string :postcode
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :guests
  end
end
