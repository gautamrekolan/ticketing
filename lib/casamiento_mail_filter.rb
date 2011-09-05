class CasamientoMailFilter < DefaultMailFilter
  
  def filter!
    if paypal_notification?
      process!
      puts postal_address

    else
      return false
    end
  end

  def paypal_notification?
    if @email.subject =~ /Notification of an Instant Payment Received from/
      true
    else
      false
    end
  end
  
  def subject_to_match
    @email.subject
  end
  
  def addresses_to_match
    from_addresses_in_email
  end
  
  def from_addresses_in_email
    @email.subject =~ /\((.*)\)/
    [ $1 ]
  end
  
  def reply_to_addresses_in_email
    []
  end
  
  def ebay_user_id
    @email.subject =~ /from (.+) \(/
    $1
  end
  
  def postal_address
    b = @email.body.gsub("\r\n", "\n")
    b =~ /Confirmed postal address(.*)\n\n\n\nNote/m
    $1
  end

end


