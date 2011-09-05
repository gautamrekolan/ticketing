class Conversation < ActiveRecord::Base
	belongs_to :customer, :inverse_of => :conversations
	has_many :messages, :inverse_of => :conversation
	has_many :ebay_messages, :inverse_of => :conversation
	
	validates :customer, :presence => true
	
	scope :open, where(:status => false) 
	
	def self.with_matching_subject(subject = "")
	  includes(:messages, :ebay_messages).where("messages.subject = ? or ebay_messages.subject = ?", subject, subject)
	end
	
	def self.with_matching_eias_token(token = "")
	  includes(:customer).where(:customer => { :eias_token => token })
	end
	
	def self.with_matching_email_addresses(emails = [])
	  includes(:customer => :customer_emails).where(:customer_emails => { :address => emails })
	end
	
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

