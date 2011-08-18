require 'test_helper'

class ConversationMailerTest < ActionMailer::TestCase
  # replace this with your real tests
  test "the truth" do
    assert true
  end
  
  def test_reply_mailer
    message = OutgoingMessage.new(:content => "This is the body of the message!", :subject => "This is the subject of the message!")
    customer_emails = [CustomerEmail.new(:address => "david.pettifer@dizzy.co.uk"), CustomerEmail.new(:address => "david.p@casamiento-cards.co.uk") ]
      message.sent_to_addresses = customer_emails
      message.save!
     email = ConversationMailer.reply(message).deliver
     pp email.to
  end
end
