class RawEmail < ActiveRecord::Base
	belongs_to :message
end

# == Schema Information
#
# Table name: raw_emails
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  message_id :integer
#

