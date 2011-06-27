class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.text :content
      t.integer :conversation_id
      t.date :datetime
    end
  end

  def self.down
    drop_table :messages
  end
end
