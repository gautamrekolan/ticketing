class Order < ActiveRecord::Base
	belongs_to :customer
	has_one :customer_address
	has_many :items, :dependent => :destroy
	has_many :monograms
end
