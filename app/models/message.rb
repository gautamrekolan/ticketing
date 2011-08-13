class Message < ActiveRecord::Base
	has_many :attachments, :dependent => :destroy
	has_one :reply_to_address, :class_name => "CustomerEmail", :foreign_key => "reply_to_id"
end
