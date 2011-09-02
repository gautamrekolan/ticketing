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
#imap = Net::IMAP.new("imap.googlemail.com", 993, true)

#imap.login("checkout.charlie.1980@gmail.com", "12thjuly1995")
#imap.select("Inbox")

#message_ids = imap.uid_search('ALL')
#imap.uid_fetch(message_ids, ["RFC822"]).each do |msg|
  #uid = msg.attr['UID']
  #Incoming.receive(msg.attr['RFC822'])  
  
  #Rails.logger.info("IMPORTED EMAIL: uid " + uid.to_s)

  #File.open("emails/#{id}.eml", "wb") { |f| f.write(rfc) }
  #imap.uid_copy(uid, "[Gmail]/All Mail")
  # imap.uid_store(uid, "+FLAGS", [:Deleted])
   
 # Rails.logger.info("DELETED EMAIL: uid " + uid.to_s)
   #imap.expunge
   
#end

Dir.foreach("../emails") do |email|
if email == "." || email == ".."

else
  email = File.open("../emails/" + email,'rb') { |f| f.read }
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
