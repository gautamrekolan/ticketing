class OutgoingMessage < ActiveRecord::Base
  has_and_belongs_to_many :sent_to_addresses, :class_name => "CustomerEmail"
  
  def sent_to
    sent_to_addresses.map(&:address)
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

