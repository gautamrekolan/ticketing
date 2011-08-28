class EbayMessage < ActiveRecord::Base
	belongs_to :conversation, :inverse_of => :ebay_messages
	belongs_to :customer_email, :inverse_of => :ebay_messages
	#validates :subject, :presence => true
	#validates :conversation, :presence => true
	#validates :datetime, :presence => true

end


# == Schema Information
#
# Table name: ebay_messages
#
#  id              :integer         not null, primary key
#  customer_id     :integer
#  item_number     :string(255)
#  subject         :string(255)
#  content         :text
#  date            :datetime
#  conversation_id :integer
#

