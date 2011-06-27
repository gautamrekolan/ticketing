class Incoming < ActionMailer::Base
  default :from => "from@example.com"
  
  def receive(email)
    process_mail(email)
    p email
  end
  
  def process_body(mail)
    @body = mail.body.decoded
    if @body =~ /CASAMIENTO\[(.*)\]/
      @ticket_id = $1
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
  
  def process_multipart(mail)
    if mail.content_type =~ /alternative/
      process_multipart_alternative(mail.parts)
    elsif mail.multipart?
      process_parts(mail.parts)
    else
      puts mail.content_type
    end
  end

  def process_mail(mail)
    if mail.multipart?
      process_multipart(mail)
    else
      process_body(mail)
    end	
  end
end
