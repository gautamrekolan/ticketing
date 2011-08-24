class ProductFormat < ActiveRecord::Base
has_many :product_formats
end

# == Schema Information
#
# Table name: product_formats
#
#  id          :integer         not null, primary key
#  description :string(255)
#  height      :integer
#  width       :integer
#  style       :string(255)
#

