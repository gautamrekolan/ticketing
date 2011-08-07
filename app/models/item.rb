class Item < ActiveRecord::Base
	belongs_to :order
	belongs_to :product
	has_and_belongs_to_many :guests
	accepts_nested_attributes_for :guests
	
	validates :order, :presence => true
	validates :product, :presence => true
	validates :price, :presence => true
	validates :quantity_ordered, :presence => true
	
	def guests_remaining
		quantity_ordered - guests.count 
	end

end
