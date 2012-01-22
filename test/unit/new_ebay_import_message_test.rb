require 'test_helper'

class EbayImportMessageTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

  test "import messages" do
    ImportEbayMessages.new.import!
    pp Customer.all
    pp EbayMessage.all
  end
end
