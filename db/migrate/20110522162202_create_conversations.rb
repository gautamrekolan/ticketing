class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      t.integer :customer_id
      t.string :ticket
    end
  end

  def self.down
    drop_table :conversations
  end
end
