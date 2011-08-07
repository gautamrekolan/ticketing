class Monogram < ActiveRecord::Base
	validates :description, :presence => true
end
