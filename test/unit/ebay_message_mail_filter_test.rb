require 'test_helper'
require 'pp'

class EbayMessageMailFilterTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
  WebMock.allow_net_connect! 
    @mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/ebay_message.eml')
  end

	def test_subject_matches
	  assert EbayMessageFilter.new(@mail).filter!
    pp Customer.all
    
  end
  
  
end
