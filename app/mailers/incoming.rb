class Incoming < ActionMailer::Base

  def receive(email)    
	  mail = ParsedMail.new(email)
	  filters = [PayPalMailFilter, DefaultMailFilter ]
	  begin
	  filters.each do |f|
	    if f.new(mail).filter!
	      break
	    end
	  end
	  
	  rescue
	    DefaultMailFilter.new(mail).filter!
	  end
  end  

end
