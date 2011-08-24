class Product < ActiveRecord::Base
belongs_to :theme
belongs_to :product_type
belongs_to :product_format
has_many :items
belongs_to :paper
def description
	theme.name + ", " + product_type.description + ", " + product_format.description
end


end

# == Schema Information
#
# Table name: products
#
#  id                :integer         not null, primary key
#  product_type_id   :integer
#  product_format_id :integer
#  theme_id          :integer
#  paper_id          :integer
#  price             :integer
#

