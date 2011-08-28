require 'pp'

class ImportEbayMessages

  def initialize
    @ebay_api = Ebay::Api::Trading.new("https://api.ebay.com/ws/api.dll", "AgAAAA**AQAAAA**aAAAAA**Xsj9TQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wAkIKmDpaCogudj6x9nY+seQ**oy4BAA**AAMAAA**7G9IaBQ1Eyr+vFVt0tC6qS15Xkq7ooTmGQ2mn6ZwBerzeIyGHYbU2QV8W5Z44rzoABqCTdSGXLgNC1nrI9bm5fr8owxtt8S0QmYazfHnQWbrpcJol5Z7yMVXX8nl45oN0x3F0dVhHNOYzWnyO3agwQwxSBEJ+puIV421bzMd2XlIzNTb7UsZMabi5Xiw94fqzRkp1YZsKYLcsCxRzYOyh8xOQ5HElSkKsGRRaFrHgGQzVUbOij7PTOpv+BaExKwUXlW4UuuWxXCr3HnmXVDVbeRamFP3nAoGH8UgxNMQTgVEPgN0NFOPf6uUNbKA75Vj5cKSMie/qtM+RbTi1RIdbwWIpS4eK3RSOJDEpg4YFGeHlBm2y436vXgC1yavCnrYaSBKthamhU1Gd+Dw+Ps0ZdM13HlE4gF3oCvk8BGA30jTlsExTpU3kYL+8JJILvlrGWX+ei3uIYopH8AHhZ6DD/YZz7+Id9SiMkhV+Ad9wz5r2t+hLH4ts4Y/jpznjp3m4iAdhgwxVaN/XLEzALvQ08ranvSy7mK78ddRAaCyJq/okHqv6nKn5vVhoHzJDJKdZryR7otqyj6OgqediAcy8PiMFuRFAB/lMOfxTWOYGLG/kIjC0nOaKse177UfM2jAnn+dTYxeE6i4hjpxsa/2T4tamUHYle3hXn5GtuTdnXDTCOxHvJuCajfHmwcAZ29jZUBwULIpl8RELRx3MGaMH5pY/eTWqyeIZuGFZHvzIEKxT9cieDnGi1thHvw+EpHo", "Casmient-178b-402d-98a6-51e19780d9a0", "c0cf2bdb-6ae9-4430-964d-16115594c412", "c8d4d396-f869-44d9-8798-df4c2de90717", "727")
  end
  
  def import!
    get_member_messages = @ebay_api.request(:GetMemberMessages, :MailMessageType => "All")
    messages = get_member_messages["GetMemberMessagesResponse"]["MemberMessage"]["MemberMessageExchange"]
    messages.each do |m|
      item = m["Item"]
      item_number = item["ItemID"] unless item.blank?
      receive_date = m["CreationDate"]
      status = m["MessageStatus"]

      q = m["Question"]
        message_id = q["MessageID"]    
        subject = q["Subject"]
        ebay_user_id = q["SenderID"]
        sender_email = q["SenderEmail"]
        content = q["Body"]
        
      email = CustomerEmail.find_or_initialize_by_address(sender_email)
      conversation = find_conversation_by_ebay_user_and_subject(ebay_user_id, subject, sender_email)
      if !conversation.blank?
        conversation.ebay_messages.build(:subject => subject, :content => content, :date => receive_date, :ebay_message_identifier => message_id, :item_number => item_number, :customer_email => email)
        conversation.save!
      else
        customer = Customer.find_or_initialize_by_ebay_user_id(ebay_user_id)
        customer.name = ebay_user_id
        conversation = customer.conversations.build
        conversation.ebay_messages.build(:subject => subject, :content => content, :date => receive_date, :ebay_message_identifier => message_id, :item_number => item_number, :customer_email => email)
        conversation.save!
        customer.save!
      end
    end
  end
      def find_conversation_by_ebay_user_and_subject(ebay_user_id, subject, address)
      Conversation.includes(:messages, :ebay_messages, :customer => :customer_emails).where("customers.ebay_user_id = ? or customer_emails.address = ? and messages.subject = ? or ebay_messages.subject = ?", ebay_user_id, address, subject,  subject).limit(1).first
    end
    
end
