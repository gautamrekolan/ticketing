class Incoming < ActionMailer::Base

  def receive(email)    
	  mail = ParsedMail.new(email)
	  CasamientoMailFilter.new(mail).filter!
  end
  

end
