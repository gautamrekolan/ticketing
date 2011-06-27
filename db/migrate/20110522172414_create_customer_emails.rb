class CreateCustomerEmails < ActiveRecord::Migration
  def self.up
    create_table :customer_emails do |t|
      t.string :address
      t.integer :customer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :customer_emails
  end
end
