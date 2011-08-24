
class Message < ActiveRecord::Base
	has_many :attachments, :dependent => :destroy
	belongs_to :conversation, :inverse_of => :messages
	has_and_belongs_to_many :reply_to_addresses, :class_name => "CustomerEmail",  :join_table => "messages_reply_to_addresses"
	has_and_belongs_to_many :from_addresses, :class_name => "CustomerEmail", :join_table => "messages_from_addresses"
	has_one :raw_email, :dependent => :destroy
	
	validates :subject, :presence => true
	validates :conversation, :presence => true
	validates :datetime, :presence => true
	
	def all_addresses
	  reply_to_addresses + from_addresses
	end
end

# == Schema Information
#
# Table name: messages
#
#  id              :integer         not null, primary key
#  content         :text
#  subject         :string(255)
#  conversation_id :integer
#  datetime        :datetime
#

