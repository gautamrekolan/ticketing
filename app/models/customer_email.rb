class CustomerEmail < ActiveRecord::Base
	belongs_to :customer
	has_and_belongs_to_many :messages_from, :class_name => "Message", :join_table => :messages_from_addresses
	has_and_belongs_to_many :messages_to, :class_name => "Message", :join_table => :messages_reply_to_addresses
	has_many :ebay_messages
	validates :address, :presence => true, :uniqueness => true
end

# == Schema Information
#
# Table name: customer_emails
#
#  id          :integer         not null, primary key
#  address     :string(255)
#  customer_id :integer
#

