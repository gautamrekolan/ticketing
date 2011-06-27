class Conversation < ActiveRecord::Base
	belongs_to :customer
	has_many :messages
end
