class Paper < ActiveRecord::Base
	has_many :products
	validates :weight, :numericality => true, :presence => true
	validates :colour, :presence => true
	validates :texture, :presence => true

	def description
		"#{weight}gsm #{colour} #{texture}"
	end

end
