class CustomerEmail < ActiveRecord::Base
	belongs_to :customer
	validates :address, :presence => true
end
