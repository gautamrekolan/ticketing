require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

  test "message has from address" do
    message = Message.new(:content => "Here is the body!", :datetime => Time.now)
    message.from_addresses.build(:address => "david.pettifer@dizzy.co.uk")
    message.reply_to_addresses.build(:address => "rebelcoo7@hotmail.com")
	message.reply_to_addresses.build(:address => "lucy@denver.com")
    message.save
    pp message.reply_to_addresses
pp message.from_addresses
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

