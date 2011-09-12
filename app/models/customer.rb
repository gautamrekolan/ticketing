class Customer < ActiveRecord::Base

	has_many :orders, :dependent => :destroy
	has_many :mail_merge_guests
	accepts_nested_attributes_for :mail_merge_guests
	has_many :customer_addresses, :dependent => :destroy
	has_many :customer_emails, :dependent => :destroy
	has_many :conversations, :dependent => :destroy, :inverse_of => :customer
	
	validates :name, :presence => true
	validates :eias_token, :uniqueness => true, :allow_blank => true
	validates :ebay_user_id, :uniqueness => true, :allow_blank => true
	
	def self.where_email_addresses_or_eias_token_match(emails, eias_token)
	  includes(:customer_emails).where("customer_emails.address IN (?) or customers.eias_token = ?", emails, eias_token)
	end
	
	def self.where_email_addresses_match(emails)
	  includes(:customer_emails).where(:customer_emails => { :address => emails })
	end
	
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

# == Schema Information
#
# Table name: customers
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  eias_token   :string(255)
#  ebay_user_id :string(255)
#

