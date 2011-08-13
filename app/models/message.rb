class Message < ActiveRecord::Base
	has_many :attachments, :dependent => :destroy
	has_and_belongs_to_many :reply_to_addresses, :class_name => "CustomerEmail", :foreign_key => "reply_to_address_id", :join_table => "messages_reply_to_addresses"
	has_and_belongs_to_many :from_addresses, :class_name => "CustomerEmail", :foreign_key => "from_address_id", :join_table => "messages_from_addresses"
end
