class MailMergeGuestsController < ApplicationController
	
	before_filter :load_customer

	def update
    	@customer.update_attributes(params[:customer])
	end
	
	def destroy
		if params[:id]
		else
			@customer.mail_merge_guests.delete_all
		end
	end
	
	private
	
	def load_customer	
		@customer = Customer.find(params[:customer_id])
	end
	
end
