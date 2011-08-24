class Item < ActiveRecord::Base
	belongs_to :order
	belongs_to :product
	has_and_belongs_to_many :guests
	accepts_nested_attributes_for :guests
	
	validates :product, :presence => true
	validates :price, :presence => true
	validates :quantity_ordered, :presence => true
	
	def guests_remaining
		quantity_ordered - guests.count 
	end

end

# == Schema Information
#
# Table name: items
#
#  id                         :integer         not null, primary key
#  product_id                 :integer
#  price                      :integer
#  quantity_ordered           :integer
#  quantity_despatched        :integer
#  order_id                   :integer
#  ebay_order_line_item_token :string(255)
#

