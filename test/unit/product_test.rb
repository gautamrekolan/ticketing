require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "blah" do 

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

