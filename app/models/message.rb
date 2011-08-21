class Message < ActiveRecord::Base
	has_many :attachments, :dependent => :destroy
	has_and_belongs_to_many :reply_to_addresses, :class_name => "CustomerEmail",  :join_table => "messages_reply_to_addresses"
	has_and_belongs_to_many :from_addresses, :class_name => "CustomerEmail", :join_table => "messages_from_addresses"
	has_one :raw_email, :dependent => :destroy
	
	def all_addresses
	  reply_to_addresses + from_addresses
	end
end
