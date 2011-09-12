require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def setup
    @customer = Factory.create(:customer)    
    @customer.customer_emails.create!(:address => "david.p@casamiento.co.uk")
    @customer.customer_emails.create!(:address => "davey@googlemail.com")
  end

  def test_a_find_by_eias_token_only
    customer = Customer.where_email_addresses_or_eias_token_match("a", "abcdefghijklmnopqrstuvwxyz")
    assert_equal "mister-dizzy", customer.first.ebay_user_id
  end
  
  def test_b_find_by_email_address_only
    customer = Customer.where_email_addresses_or_eias_token_match("davey@googlemail.com", nil)
    assert_equal "mister-dizzy", customer.first.ebay_user_id
  end
  
  def test_c_find_by_email_addresses
    customer = Customer.where_email_addresses_or_eias_token_match(["henry@lewis.com", "davey@googlemail.com"], nil)
    assert_equal "mister-dizzy", customer.first.ebay_user_id
  end
  
  def test_d_find_by_email_addresses_and_eias_token
    customer = Customer.where_email_addresses_or_eias_token_match(["henry@lewis.com", "davey@googlemail.com"], "abcdefghijklmnopqrstuvwxyz")
    assert_equal "mister-dizzy", customer.first.ebay_user_id
  end 
  
end

# == Schema Information
#
# Table name: customers
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  eias_token   :string(255)
#  ebay_user_id :string(255)
#

