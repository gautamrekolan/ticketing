class GuestFilesController < ApplicationController
	
	before_filter :load_customer
	
	def create
		@guests = @customer.mail_merge_guests.send(params[:select]).collect(&:address_to_array)
		xml = Casamiento::MailMerge::XMLFormatter.new(@guests, params[:guest_file]).output	
		send_data xml, :type => "text/xml"
	end
	
	def load_customer
		@customer = Customer.find(params[:customer_id])
	end
end
