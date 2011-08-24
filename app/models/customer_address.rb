class CustomerAddress < ActiveRecord::Base

	belongs_to :customer
	has_many :orders
	
end

# == Schema Information
#
# Table name: customer_addresses
#
#  id              :integer         not null, primary key
#  customer_id     :integer
#  name            :string(255)
#  company         :string(255)
#  address_1       :string(255)
#  address_2       :string(255)
#  town            :string(255)
#  county          :string(255)
#  country         :string(255)
#  postcode        :string(255)
#  ebay_address_id :string(255)
#

