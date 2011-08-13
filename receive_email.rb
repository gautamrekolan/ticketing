Mail.defaults do
  retriever_method :pop3, { :address    => "pop.gmail.com",
						  :port       => 995,
						  :user_name  => 'checkout.charlie.1980@gmail.com',
						  :password   => '12thjuly1995',
						  :enable_ssl => true }
end

Mail.all.each do |m|
	Incoming.receive(m)
end
