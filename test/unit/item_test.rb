require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: items
#
#  id                         :integer         not null, primary key
#  product_id                 :integer
#  price                      :integer
#  quantity_ordered           :integer
#  quantity_despatched        :integer
#  order_id                   :integer
#  ebay_order_line_item_token :string(255)
#

