class Paper < ActiveRecord::Base
has_many :products

	def description
		"#{weight}gsm #{colour} #{texture}"
	end

end
