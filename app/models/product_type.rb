class ProductType < ActiveRecord::Base
	has_many :products
end

# == Schema Information
#
# Table name: product_types
#
#  id          :integer         not null, primary key
#  description :string(255)
#  envelope    :boolean
#

