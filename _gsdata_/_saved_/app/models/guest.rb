class Guest < ActiveRecord::Base
	has_and_belongs_to_many :items
	validates_presence_of :item_ids

end
