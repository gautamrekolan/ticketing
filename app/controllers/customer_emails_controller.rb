class CustomerEmailsController < ApplicationController
  # GET /customer_emails
  # GET /customer_emails.xml
  def index
    @customer_emails = CustomerEmail.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customer_emails }
    end
  end

  # GET /customer_emails/1
  # GET /customer_emails/1.xml
  def show
    @customer_email = CustomerEmail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer_email }
    end
  end

  # GET /customer_emails/new
  # GET /customer_emails/new.xml
  def new
    @customer_email = CustomerEmail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer_email }
    end
  end

  # GET /customer_emails/1/edit
  def edit
    @customer_email = CustomerEmail.find(params[:id])
  end

  # POST /customer_emails
  # POST /customer_emails.xml
  def create
    @customer_email = CustomerEmail.new(params[:customer_email])

    respond_to do |format|
      if @customer_email.save
        format.html { redirect_to(@customer_email, :notice => 'Customer email was successfully created.') }
        format.xml  { render :xml => @customer_email, :status => :created, :location => @customer_email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customer_emails/1
  # PUT /customer_emails/1.xml
  def update
    @customer_email = CustomerEmail.find(params[:id])

    respond_to do |format|
      if @customer_email.update_attributes(params[:customer_email])
        format.html { redirect_to(@customer_email, :notice => 'Customer email was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_emails/1
  # DELETE /customer_emails/1.xml
  def destroy
    @customer_email = CustomerEmail.find(params[:id])
    @customer_email.destroy

    respond_to do |format|
      format.html { redirect_to(customer_emails_url) }
      format.xml  { head :ok }
    end
  end
end
