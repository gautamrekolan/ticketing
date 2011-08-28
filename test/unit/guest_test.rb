require 'test_helper'

class GuestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: guests
#
#  id                 :integer         not null, primary key
#  name_on_envelope   :string(255)
#  name_on_invitation :string(255)
#  address            :string(255)
#  postcode           :string(255)
#

