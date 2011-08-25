class Conversation < ActiveRecord::Base
	belongs_to :customer, :inverse_of => :conversations
	has_many :messages, :inverse_of => :conversation
	
	validates :customer, :presence => true
	
	scope :open, where(:status => false) 

  def subject
    @subject ||= messages.first.subject unless messages.first.nil?
    @subject = "NO SUBJECT" if @subject.blank?
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

