class Incoming < ActionMailer::Base
  default :from => "from@example.com"
  require 'pp'
  def receive(email)
    @attachments = []
    process_mail(email)
  end
  
  def process_body(mail)
    @body = mail.body.decoded
    if @body =~ /CASAMIENTO\[(.*)\]/
      @ticket_id = $1
    end
    route_email(mail)
  end
  
  def route_email(mail)
    @customer_email = CustomerEmail.find_by_address(@from)	
    begin
      @conversation = Conversation.find(@ticket_id)
    rescue ActiveRecord::RecordNotFound
      @conversation = nil
    end
  
    # Conversation not found
    if !@conversation.nil?
    
    # Conversation not found but email matched
    elsif @conversation.nil? && !@customer_email.nil?
      @conversation = Conversation.new
      @customer_email.customer.conversations << @conversation
      
    # Conversation not found and email not matched
    elsif @conversation.nil? && @customer_email.nil?
      @conversation = Conversation.new
      @customer_email = CustomerEmail.new(:address => @from)
      @customer = Customer.new(:name => mail[:from].display_names)
      @customer.customer_emails << @customer_email
      @customer.conversations << @conversation
      @customer.save!
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
