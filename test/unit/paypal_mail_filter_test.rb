require 'test_helper'
require 'pp'

class PaypalMailFilterTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    @mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/paypal.eml')
    @mail = ParsedMail.new(@mail)
  end

	def test_subject_matches
	  paypal_filter = CasamientoMailFilter.new(@mail).filter!
	  pp Message.all
	  pp Conversation.all
	  pp Customer.all
	  pp CustomerEmail.all
	end
end
