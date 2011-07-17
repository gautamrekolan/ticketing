class Customer < ActiveRecord::Base
require 'pp'
	has_many :orders, :dependent => :destroy
		has_many :mail_merge_guests
		accepts_nested_attributes_for :mail_merge_guests
		has_many :customer_addresses
	validates :name, :presence => true
	
	def new_guest_fields
		5.times.collect { mail_merge_guests.build }
	end

	def guest_file=(attributes={})
		guest_parser = Casamiento::MailMerge::LineParser.new(attributes)
		
		if guest_parser.flat_list
			all = guest_parser.all.collect { |g| { :address => g } }
			self.mail_merge_guests.build(all)
		else
			by_hand = guest_parser.by_hand.collect { |g| { :address => g.join("\n"), :hand => true } }
	  		postal = guest_parser.postal.collect { |g| { :address => g.join("\n") }}
	  		self.mail_merge_guests.build(by_hand + postal)
		end
	end
end
