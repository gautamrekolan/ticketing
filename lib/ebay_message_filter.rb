class EbayMessageFilter < DefaultMailFilter
  
  def initialize(email)
    super(email)
  	@ebay_api = EbayApiConnection.connection
  end
  
  def filter!
    if ebay_message?
      @customer_attributes = { :eias_token => eias_token, :ebay_user_id => ebay_user_id }
      process!
      return true
    else
      return false
    end
  end

  def ebay_message?
    if display_name =~ /eBay Member: /
      true
    else
      false
    end
  end
  
  def ebay_user_id
    display_name =~ /eBay Member: (.+)/
    $1
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


