class MailMergeGuest < ActiveRecord::Base
  scope :hand, where(:hand => true)
  scope :post, where(:hand => false)
  belongs_to :customer
  
   before_save { |record| record.address.gsub!(/\r\n?/, "\n") } # remove carriage returns
   
   def address_to_array
    address.split("\n")
   end
end
# == Schema Information
#
# Table name: mail_merge_guests
#
#  id          :integer         not null, primary key
#  customer_id :integer
#  address     :text
#  hand        :boolean
#

