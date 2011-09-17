require 'test_helper'

class InvoiceFormatterTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    @order = Factory.create(:order)
  
  end

  test "format" do
    puts InvoiceFormatter.new([@order]).output
  end 

end

# == Schema Information
#
# Table name: messages
#
#  id              :integer         not null, primary key
#  content         :text
#  subject         :string(255)
#  conversation_id :integer
#  datetime        :datetime
#

