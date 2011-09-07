class PayPalMailFilter < DefaultMailFilter
  
  def initialize(email)
    super(email)
  	@ebay_api = EbayApiConnection.connection
  end
  
  def filter!
    if paypal_notification?

      @customer_attributes = { :eias_token => eias_token, :ebay_user_id => ebay_user_id }
      process!
      return true
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
  
  def addresses_to_match
    from_addresses_in_email
  end
  
  def from_addresses_in_email
    @email.subject =~ /\((.*)\)/
    [ $1 ]
  end
  
  def ebay_user_id
    @email.subject =~ /from (.+) \(/
    $1
  end
  
  def postal_address
    b = content.gsub("\r\n", "\n")
    b =~ /Confirmed postal address(.*)\n\n\n\nNote/m
    $1
  end
  
  def display_name
     b = content.gsub("\r\n", "\n")
     b =~ /Buyer:\n(.+?)\n/m
     result = $1.titleize
     result
  end
  
  def eias_token
    @eias ||= get_eias_token
  end
  
  private
  
  def get_eias_token
    response = @ebay_api.request(:GetUser, :UserID => ebay_user_id)
    response["GetUserResponse"]["User"]["EIASToken"]
  end

end


