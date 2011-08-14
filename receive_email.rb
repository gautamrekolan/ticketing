#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'casamientoweddingstationery@gmail.com',
#						  :password   => 'world667',
#						  :enable_ssl => true }
#end

Mail.defaults do
   retriever_method :imap, { :address => "imap.googlemail.com",
   :port => 993,
   :user_name => 'casamientoweddingstationery@gmail.com',
   :password => 'world667',
   :enable_ssl => true }
   end
 require 'pp'

mail = Mail.find(:what => :first, :count => 42, :order => :asc) 

mail.each do |m|
	Incoming.receive(m)
end

#m = Mail.read(Rails.root.to_s + "/test/fixtures/incoming/dearbhaila.eml")
#Incoming.receive(m)
