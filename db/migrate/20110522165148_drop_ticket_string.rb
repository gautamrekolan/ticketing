class DropTicketString < ActiveRecord::Migration
  def self.up
  remove_column :conversations, :ticket
  end

  def self.down
  end
end
