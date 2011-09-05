class ParsedMail
  
  attr_reader :attachments, :body
  
  def initialize(email)
    @email = email
    @attachments = []
    parse!
  end
  
  def all_addresses
    @all_addresses = from_addresses + reply_to_addresses unless reply_to_addresses.nil? || from_addresses.nil?
	  @all_addresses ||= from_addresses unless from_addresses.nil?
	end
	
	def from_addresses
	  @from_addresses ||= @email[:from].addresses.uniq unless @email[:from].nil?
	end
	
	def reply_to_addresses
	  @reply_to_addresses ||= @email[:reply_to].addresses.uniq unless @email[:reply_to].nil?
	end
  
  def subject 
    @subject = @email.subject.gsub(/Re:/i, '').strip unless @email.subject.nil?
    if @email.subject.nil? || @subject.blank?
      @subject = "NO SUBJECT"
    else
      @subject
    end
  end
  
  def parse!
    if @email.multipart?
	  	process_body
		  process_multipart(@email)
	  else
		  @body = @email.body.decoded.force_encoding(@email.charset).encode!('utf-8')
	  end
  end
  
  def process_body  
    body = @email.text_part || @email.html_part			
		@body = body.decoded.force_encoding(body.charset).encode!('utf-8')
  end  
	
	def process_multipart(part)
		if part.multipart?
			process_parts(part.parts)
		else
			raise Exception, "Unknown content_type: #{part.content_type}"
		end
	end  
  
	def process_parts(parts)
		parts.each do |p|
			if p.multipart?
				process_multipart(p)
			elsif p.content_disposition =~ /attachment/
				@attachments << Attachment.new(:content_type => p.mime_type, :content => p.decoded, :filename => p.filename)
			end
		end
	end	
	
	def display_names
	  @email[:from].display_names unless @email[:from].nil?
	end
	
	def raw_source
	  @email.raw_source
	end
	
	def date
	  @email.date
	end

end
