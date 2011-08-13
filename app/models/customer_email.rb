class CustomerEmail < ActiveRecord::Base
	belongs_to :customer
	has_and_belongs_to_many :from_addresses
	has_and_belongs_to_many :reply_to_addresses
	validates :address, :presence => true
end
