class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :monogram
      t.integer :customer_id
      t.string :groom_name
      t.datetime :ceremony_date
      t.string :ceremony_venue
      t.string :reception_venue
      t.time :reception_time
      t.date :rsvp_date
      t.text :rsvp_address
    end
  end

  def self.down
    drop_table :orders
  end
end
