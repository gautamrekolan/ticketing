class Theme < ActiveRecord::Base
	validates :name, :presence => true, :uniqueness => true
	has_many :products
end

# == Schema Information
#
# Table name: themes
#
#  id   :integer         not null, primary key
#  name :string(255)
#

