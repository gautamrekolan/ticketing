class MailFilter
  def initialize(email)
    @email = email
  end
  
  def paypal_notification?
    if @email.subject =~ /Notification of an Instant Payment Received from/
      true
    else
      false
    end
  end
  
  def paypal_address
    @email.subject =~ /\((.*)\)/
    $1
  end
  
  def ebay_user_id
    @email.subject =~ /from (.+) \(/
    $1
  end

end
