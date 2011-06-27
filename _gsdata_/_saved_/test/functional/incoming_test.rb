require '../test_helper'

class IncomingTest < ActionMailer::TestCase
  # replace this with your real tests
  test "the truth" do
    assert true
  end
  
  def test_mailer
    email = File.open("../fixtures/emails/multipart_mixed.eml")
    Incoming.receive(email)
  end
end
