#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'casamientoweddingstationery@gmail.com',
#						  :password   => 'world667',
#						  :enable_ssl => true }
#end
#class ReceiveEmail
#	def self.import
require 'net/imap'
require 'pp'
#Mail.defaults do
#   retriever_method :imap, { :address => "imap.googlemail.com",
#   :port => 993,
#   :user_name => 'casamientoweddingstationery@gmail.com',
#   :password => 'world667',
#   :enable_ssl => true }
#  end
#source = Net::IMAP.new("imap.googlemail.com", 993, true)

#source.login("casamientoweddingstationery@gmail.com", "world667")
#source.select("[Gmail]/All Mail")


#message_ids = source.uid_search('ALL')
#message_ids.each do |id| 

#  rfc = source.uid_fetch(id, ["RFC822"])[0].attr['RFC822']
 # File.open("emails/#{id}.eml", "wb") { |f| f.write(rfc) }
#end

Dir.foreach("emails") do |email|
if email == "." || email == ".."

else
  email = File.open('emails/' + email,'rb') { |f| f.read }
  Incoming.receive(email)
  puts "Parsing ..."
  end
end


#mail = Mail.find(:count => 1000, :order => :desc, :mailbox => '[Gmail]/All Mail') 

#mail.each do |m|
#	Incoming.receive(m)
#	puts "Parsed.... {m.subject}"
#end

#m = Mail.read(Rails.root.to_s + "/test/fixtures/incoming/dear.eml")
#Incoming.receive(m)
#end
