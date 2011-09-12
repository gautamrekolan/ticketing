class Incoming < ActionMailer::Base

  def receive(email)    
	  filters = [PayPalMailFilter, EbayMessageFilter, DefaultMailFilter ]
	  begin
	    filters.each do |f|
	      if f.new(email).filter!
	        break
	      end
	    end
	  
	  rescue Exception
	    DefaultMailFilter.new(email).filter!
	  end
  end  

end
