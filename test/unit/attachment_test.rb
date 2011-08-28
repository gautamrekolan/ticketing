require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
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

