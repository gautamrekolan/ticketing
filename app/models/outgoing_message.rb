class OutgoingMessage < ActiveRecord::Base
  has_and_belongs_to_many :sent_to_addresses, :class_name => "CustomerEmail"
  
  def sent_to
    sent_to_addresses.map(&:address)
  end
end
