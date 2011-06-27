class Customer < ActiveRecord::Base
	has_many :orders, :dependent => :destroy
	
	validates :name, :presence => true
	validates :address, :presence => true
end
