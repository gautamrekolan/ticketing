class Monogram < ActiveRecord::Base
	validates :description, :presence => true
end

# == Schema Information
#
# Table name: monograms
#
#  id          :integer         not null, primary key
#  description :string(255)
#

