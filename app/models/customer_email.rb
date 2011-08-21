class CustomerEmail < ActiveRecord::Base
	belongs_to :customer
	has_and_belongs_to_many :messages_from, :class_name => "Message", :join_table => :messages_from_addresses
	has_and_belongs_to_many :messages_to, :class_name => "Message", :join_table => :messages_reply_to_addresses
	validates :address, :presence => true
end
