class Paper < ActiveRecord::Base
	has_many :products
	validates :weight, :numericality => true, :presence => true
	validates :colour, :presence => true
	validates :texture, :presence => true

	def description
		"#{weight}gsm #{colour} #{texture}"
	end

end

# == Schema Information
#
# Table name: papers
#
#  id      :integer         not null, primary key
#  weight  :integer
#  texture :string(255)
#  colour  :string(255)
#

