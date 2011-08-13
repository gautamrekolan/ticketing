#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'checkout.charlie.1980@gmail.com',
#						  :password   => '12thjuly1995',
#						  :enable_ssl => true }
#end
#@results = Mail.all
require 'pp'
require 'email_parser'

alternative_1 = Mail.read("test/fixtures/incoming/gmail.eml")

