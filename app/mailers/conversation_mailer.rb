class ConversationMailer < ActionMailer::Base
  default :from => "checkout.charlie.1980@gmail.com"

  def reply(message)
    @message = message
    mail(:to => @message.sent_to)     
  end
end
