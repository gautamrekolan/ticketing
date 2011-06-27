class Order < ActiveRecord::Base
	belongs_to :customer
	has_many :items, :dependent => :destroy
	has_many :monograms
end
