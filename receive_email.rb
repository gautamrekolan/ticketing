#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'casamientoweddingstationery@gmail.com',
#						  :password   => 'world667',
#						  :enable_ssl => true }
#end
#class ReceiveEmail
#	def self.import
Mail.defaults do
   retriever_method :imap, { :address => "imap.googlemail.com",
   :port => 993,
   :user_name => 'casamientoweddingstationery@gmail.com',
   :password => 'world667',
   :enable_ssl => true }
  end



mail = Mail.find(:count => 500, :order => :desc, :mailbox => '[Gmail]/All Mail') 

mail.each do |m|
	Incoming.receive(m)
end

#m = Mail.read(Rails.root.to_s + "/test/fixtures/incoming/dear.eml")
#Incoming.receive(m)
#end
