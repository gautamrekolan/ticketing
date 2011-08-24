class Guest < ActiveRecord::Base
	has_and_belongs_to_many :items
	validates_presence_of :item_ids

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

