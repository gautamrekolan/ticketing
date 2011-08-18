class Conversation < ActiveRecord::Base
	belongs_to :customer
	has_many :messages
	
	scope :open, where(:status => false) 

  def subject
    @subject ||= messages.first.subject
  end
end
