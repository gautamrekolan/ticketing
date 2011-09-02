class Conversation < ActiveRecord::Base
	belongs_to :customer, :inverse_of => :conversations
	has_many :messages, :inverse_of => :conversation
	has_many :ebay_messages, :inverse_of => :conversation
	
	validates :customer, :presence => true
	
	scope :open, where(:status => false) 
	
	def all_messages
	  (ebay_messages + messages).sort_by { |m| m.datetime } 
	end

  def subject
    if messages.first.nil?
      @subject = ebay_messages.first.subject
    else
      @subject = messages.first.subject
    end
    @subject
  end
end

# == Schema Information
#
# Table name: conversations
#
#  id          :integer         not null, primary key
#  customer_id :integer
#  status      :boolean
#

