class Product < ActiveRecord::Base
belongs_to :theme
belongs_to :product_type
belongs_to :product_format

def description
	theme.name + ", " + product_type.description + ", " + product_format.description
end

end
