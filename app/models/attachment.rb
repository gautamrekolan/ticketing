class Attachment < ActiveRecord::Base
belongs_to :message
end

# == Schema Information
#
# Table name: attachments
#
#  id           :integer         not null, primary key
#  message_id   :integer
#  filename     :string(255)
#  content      :binary
#  content_type :string(255)
#

