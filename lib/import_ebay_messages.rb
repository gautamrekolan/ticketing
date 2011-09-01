require 'pp'

class ImportEbayMessages

  def initialize
  			@ebay_api = Ebay::Api::Trading.new("https://api.sandbox.ebay.com/ws/api.dll", "AgAAAA**AQAAAA**aAAAAA**kRoiTg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCpQ6dj6x9nY+seQ**JpMBAA**AAMAAA**oZA6Ywa6Ma6zNlkw3cqilP+685HQPlP4Bf1XAf+2Rt9V77dU94zFnoj4nhflnUipahn1Fy2roxApfA5ELDRgedWuspTUBirBQ5bAsuq9Btysg3p4KCq5+vsLLi3gyElWAOOOEvjTe24GHXDyHxrJsci0Ht3gMvOQ0rllbdiplsymNRY0+lXrS4jGrLRV3VCwbA2rAuhDhEaJbBH0GNP+YRO2GEerOQUGmA1/zeGYOfa/ZyU/7vQYZoBFG+v+31rxfqlOVo53o9lOo2QVfI1TDRtlsQBaBe159Shbe686AdRod5zAlimUtpzV9/9OqeMDGHqjWi39CsCjTDctOsLm3Ck/h8nJcOkOHCa2aDvW1ney+77L8HljBIBCNBkNookq13s51zRjQh+vekwBi2ja0hZgIlKULFp3QZdF8np9qlhPjWT90udSQiy2hczfFQmK/vCW2dY8OD+6bcPLQa/ruTVMMLQKga3Hdi4oFxJlhLcH3hpi4Z4vunOYnxGhtva2iQpLUfRBwHpCNr2swDQDT8Y4BLkn0GpNAqaOBX700f+uywf0BnOwYwdyL7+kx/8TMR0lwTJvmlPguukEY/zMtrTIChiX6sDAAXTep9H5plEvUKmBwwqxo+Jy15kIkkmMQh5eq58I+/Zw+PWF7sNn7rWLTQyqexrPImWG3hqQlNF2O4F29DWQCfKtiD+Y+RzOF3vngtgeQmCbdWKnP9OXaxIitTuRsDagj5ebjU0DNWkX5/6eQlDScp3fVMNi0pgf", "Casmient-2aff-4dab-9163-50f440216b96", "454dd9f0-47d0-4871-ab91-ab0038a59cd3", "c8d4d396-f869-44d9-8798-df4c2de90717", "727")
    #@ebay_api = Ebay::Api::Trading.new("https://api.ebay.com/ws/api.dll", "AgAAAA**AQAAAA**aAAAAA**Xsj9TQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wAkIKmDpaCogudj6x9nY+seQ**oy4BAA**AAMAAA**7G9IaBQ1Eyr+vFVt0tC6qS15Xkq7ooTmGQ2mn6ZwBerzeIyGHYbU2QV8W5Z44rzoABqCTdSGXLgNC1nrI9bm5fr8owxtt8S0QmYazfHnQWbrpcJol5Z7yMVXX8nl45oN0x3F0dVhHNOYzWnyO3agwQwxSBEJ+puIV421bzMd2XlIzNTb7UsZMabi5Xiw94fqzRkp1YZsKYLcsCxRzYOyh8xOQ5HElSkKsGRRaFrHgGQzVUbOij7PTOpv+BaExKwUXlW4UuuWxXCr3HnmXVDVbeRamFP3nAoGH8UgxNMQTgVEPgN0NFOPf6uUNbKA75Vj5cKSMie/qtM+RbTi1RIdbwWIpS4eK3RSOJDEpg4YFGeHlBm2y436vXgC1yavCnrYaSBKthamhU1Gd+Dw+Ps0ZdM13HlE4gF3oCvk8BGA30jTlsExTpU3kYL+8JJILvlrGWX+ei3uIYopH8AHhZ6DD/YZz7+Id9SiMkhV+Ad9wz5r2t+hLH4ts4Y/jpznjp3m4iAdhgwxVaN/XLEzALvQ08ranvSy7mK78ddRAaCyJq/okHqv6nKn5vVhoHzJDJKdZryR7otqyj6OgqediAcy8PiMFuRFAB/lMOfxTWOYGLG/kIjC0nOaKse177UfM2jAnn+dTYxeE6i4hjpxsa/2T4tamUHYle3hXn5GtuTdnXDTCOxHvJuCajfHmwcAZ29jZUBwULIpl8RELRx3MGaMH5pY/eTWqyeIZuGFZHvzIEKxT9cieDnGi1thHvw+EpHo", "Casmient-178b-402d-98a6-51e19780d9a0", "c0cf2bdb-6ae9-4430-964d-16115594c412", "c8d4d396-f869-44d9-8798-df4c2de90717", "727")
  end
  
  def import!
    get_member_messages = @ebay_api.request(:GetMemberMessages, :MailMessageType => "All", :StartCreationTime => "2011-07-01T00:00:00Z")
    messages = get_member_messages["GetMemberMessagesResponse"]["MemberMessage"]["MemberMessageExchange"]

    messages.each do |m|
     

        account_email = get_user(item_number, ebay_user_id, q) unless item_number.blank?
      
      email = CustomerEmail.find_or_initialize_by_address(sender_email) unless sender_email.blank?
      account_email = CustomerEmail.find_or_initialize_by_address(account_email) unless account_email == "Invalid Request"
      conversation = find_conversation_by_ebay_user_or_email_address_and_subject(ebay_user_id, subject, sender_email)

      if conversation.blank?
        customer = Customer.find_or_initialize_by_ebay_user_id(ebay_user_id)
        conversation = customer.conversations.build
        customer.name = ebay_user_id if customer.new_record?
      end
      conversation.ebay_messages.build(:subject => subject, :content => content, :date => receive_date, :ebay_message_identifier => message_id, :item_number => item_number, :customer_email => email)
      
      conversation.customer.customer_emails << email if !email.blank? && email.new_record?
      conversation.customer.customer_emails << account_email if !account_email.blank? && account_email.new_record?
      customer.save!
    end
  end
  
  def find_conversation_by_ebay_user_or_email_address_and_subject(ebay_user_id, subject, address)
    Conversation.includes(:messages, :ebay_messages, :customer => :customer_emails).where("(customers.ebay_user_id = ? and (ebay_messages.subject = ? or messages.subject =? )) OR (customer_emails.address = ? AND (ebay_messages.subject = ? or messages.subject = ?))", ebay_user_id, subject, subject, address, subject, subject).limit(1).first
  end
    
end

class ImportedEbayMessage
  def initialize(response)
    @response = response
  end
  
  def item
    @response["Item"]
  end
  
  def item_number
    item["ItemID"]
  end
  
  def creation_date
    item["CreationDate"]
  end
  
  def question
    @response["Question"]
  end
  
  def message_id
    question["MessageID"]    
  end
    
  def subject
    question["Subject"]
  end
  
  def ebay_user_id 
    question["SenderID"]
  end
  
  def body
    question["Body"]
  end
  
  def sender_email
    q["SenderEmail"] unless q["SenderEmail"] == "Invalid Request"
  end
  
  def get_user
    user = @connection.request(:GetUser, :ItemID => item_number, :UserID => user_id)
  end
  
  def connection
    @connection ||= Ebay::Api::Trading.new("https://api.sandbox.ebay.com/ws/api.dll", "AgAAAA**AQAAAA**aAAAAA**kRoiTg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCpQ6dj6x9nY+seQ**JpMBAA**AAMAAA**oZA6Ywa6Ma6zNlkw3cqilP+685HQPlP4Bf1XAf+2Rt9V77dU94zFnoj4nhflnUipahn1Fy2roxApfA5ELDRgedWuspTUBirBQ5bAsuq9Btysg3p4KCq5+vsLLi3gyElWAOOOEvjTe24GHXDyHxrJsci0Ht3gMvOQ0rllbdiplsymNRY0+lXrS4jGrLRV3VCwbA2rAuhDhEaJbBH0GNP+YRO2GEerOQUGmA1/zeGYOfa/ZyU/7vQYZoBFG+v+31rxfqlOVo53o9lOo2QVfI1TDRtlsQBaBe159Shbe686AdRod5zAlimUtpzV9/9OqeMDGHqjWi39CsCjTDctOsLm3Ck/h8nJcOkOHCa2aDvW1ney+77L8HljBIBCNBkNookq13s51zRjQh+vekwBi2ja0hZgIlKULFp3QZdF8np9qlhPjWT90udSQiy2hczfFQmK/vCW2dY8OD+6bcPLQa/ruTVMMLQKga3Hdi4oFxJlhLcH3hpi4Z4vunOYnxGhtva2iQpLUfRBwHpCNr2swDQDT8Y4BLkn0GpNAqaOBX700f+uywf0BnOwYwdyL7+kx/8TMR0lwTJvmlPguukEY/zMtrTIChiX6sDAAXTep9H5plEvUKmBwwqxo+Jy15kIkkmMQh5eq58I+/Zw+PWF7sNn7rWLTQyqexrPImWG3hqQlNF2O4F29DWQCfKtiD+Y+RzOF3vngtgeQmCbdWKnP9OXaxIitTuRsDagj5ebjU0DNWkX5/6eQlDScp3fVMNi0pgf", "Casmient-2aff-4dab-9163-50f440216b96", "454dd9f0-47d0-4871-ab91-ab0038a59cd3", "c8d4d396-f869-44d9-8798-df4c2de90717", "727")
  end
  
end
