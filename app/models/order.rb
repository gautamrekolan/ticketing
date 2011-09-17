class Order < ActiveRecord::Base
	belongs_to :customer
	belongs_to :customer_address, :inverse_of => :orders
	has_many :items, :dependent => :destroy
	has_many :monograms
	
	validates :customer, :presence => true
end

# == Schema Information
#
# Table name: orders
#
#  id                    :integer         not null, primary key
#  monogram              :integer
#  customer_id           :integer
#  customer_address_id   :integer
#  ebay_order_identifier :string(255)
#  status                :string(255)
#  notes                 :text
#  created_at            :datetime
#  updated_at            :datetime
#

