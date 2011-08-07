class Order < ActiveRecord::Base
	belongs_to :customer
	belongs_to :customer_address
	has_many :items, :dependent => :destroy
	has_many :monograms
	
	validates :customer, :presence => true
end
