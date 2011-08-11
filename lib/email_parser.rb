class EmailParser

attr_reader :ticket_id, :body, :attachments

	def initialize(email)
		@email = email
		@attachments = []
		if @email.multipart?
			process_multipart(@email)
		else
			process_body(@email)
		end	
	end
	
	def from
		@email.from
	end
	
	def subject
		@email.subject
	end
	
	def process_multipart(mail)
		if mail.content_type =~ /alternative/
			process_multipart_alternative(mail.parts)
		elsif mail.multipart?
			process_parts(mail.parts)
		else
			raise Exception, "Unknown content_type: #{mail.content_type}"
		end
	end

	def process_multipart_alternative(parts)
		parts.each do |p|
			if p.content_type =~ /plain/
				process_body(p)
				break
			elsif p.content_type =~ /html/
				process_body(p)
				break
			end
		end
	end

	def process_body(mail)
		@body = mail.body.decoded
		if @body =~ /CASAMIENTO\[(.*)\]/
			@ticket_id = $1
		end
	end
	
	def process_parts(parts)
		parts.each do |p|
			if p.multipart?
				process_multipart(p)
			elsif p.content_disposition =~ /attachment/
				@attachments << p.content_type
			else
				process_body(p)
			end
		end
	end	
end


#alternative_1 = Mail.read("../test/fixtures/incoming/multipart_mixed.eml")
#email = EmailParser.new(alternative_1)
