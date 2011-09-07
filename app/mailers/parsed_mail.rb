class ParsedMail < Mail::Message
  
  def all_addresses
    @all_addresses = from_addresses + reply_to_addresses unless reply_to_addresses.nil? || from_addresses.nil?
	  @all_addresses ||= from_addresses unless from_addresses.nil?
	end
	
	def from_addresses
	  @from_addresses ||= self[:from].addresses.uniq unless self[:from].nil?
	end
	
	def reply_to_addresses
	  @reply_to_addresses ||= self[:reply_to].addresses.uniq unless self[:reply_to].nil?
	end
  
  def subject 
    original_subject = super
   
  end
  
  def content
   if multipart?
      new_body = text_part || html_part
		  return new_body.decoded.force_encoding(new_body.charset).encode!('utf-8')
		else
		  return body.decoded.force_encoding(body.charset).encode!('utf-8')
		end  
  end
  
	def display_names
	  self[:from].display_names unless self[:from].nil?
	end

end
