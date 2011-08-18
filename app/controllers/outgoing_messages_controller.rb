class OutgoingMessagesController < ApplicationController
  before_filter :load_parent_message

  def index
    @outgoing_messages = OutgoingMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @outgoing_messages }
    end
  end

  def show
    @outgoing_message = OutgoingMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @outgoing_message }
    end
  end

  def new
    @outgoing_message = OutgoingMessage.new
    @outgoing_message.sent_to_addresses = @parent_message.reply_to_addresses + @parent_message.from_addresses

  end

  def edit
    @outgoing_message = OutgoingMessage.find(params[:id])
  end

  def create
    @outgoing_message = OutgoingMessage.new(params[:outgoing_message])
    message = ConversationMailer.reply(@outgoing_message).deliver
    respond_to do |format|
      if @outgoing_message.save
        format.html { redirect_to(@outgoing_message, :notice => 'Outgoing message was successfully created.') }
        format.xml  { render :xml => @outgoing_message, :status => :created, :location => @outgoing_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @outgoing_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @outgoing_message = OutgoingMessage.find(params[:id])

    respond_to do |format|
      if @outgoing_message.update_attributes(params[:outgoing_message])
        format.html { redirect_to(@outgoing_message, :notice => 'Outgoing message was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @outgoing_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @outgoing_message = OutgoingMessage.find(params[:id])
    @outgoing_message.destroy

    respond_to do |format|
      format.html { redirect_to(outgoing_messages_url) }
      format.xml  { head :ok }
    end
  end
  protected
  
  def load_parent_message
    @parent_message = Message.find(params[:message_id]) if params[:message_id]
  end
end
