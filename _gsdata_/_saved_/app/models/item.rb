class Item < ActiveRecord::Base
	belongs_to :order
	belongs_to :product
	has_and_belongs_to_many :guests
	
	def guests_remaining
		quantity_ordered - guests.count 
	end

end
