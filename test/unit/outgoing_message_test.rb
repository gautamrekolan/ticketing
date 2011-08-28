require 'test_helper'

class OutgoingMessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def test_outgoing_message_has_many_sent_addresses
    outgoing = OutgoingMessage.new(:subject => "Here is a subject line", :content => "Here is the body of the message")
    customer = Customer.create!(:name => "David Pettifer")
    customer.customer_emails.build(:address => "david.pettifer@dizzy.co.uk")
    customer.customer_emails.build(:address => "lucinda.lucardi@fashion.com")
    pp customer.customer_emails
    outgoing.sent_to_addresses = customer.customer_emails
  
  end
end

# == Schema Information
#
# Table name: outgoing_messages
#
#  id         :integer         not null, primary key
#  subject    :string(255)
#  content    :text
#  message_id :integer
#  created_at :datetime
#  updated_at :datetime
#

